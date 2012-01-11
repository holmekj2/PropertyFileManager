#--
# Copyright (c) Kevin Holmes
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++require_relative 'property_files'

require 'csv'
require 'spreadsheet'
require_relative 'property_file'
require_relative 'property_file_comparator'

module PropertyFileCompareWriter
  CSV_COLUMN_HEADER = 'Property,English Text,Translated Text'
  CSV_LANGUAGE_HEADER = 'Language='
  CSV_CATEGORY_HEADER = 'Category='  
  EXCEL_COLUMN_HEADER = ['Property', 'English Text' , 'Translated Text']
  
  #Outputs number of translation errors for each property file
  def PropertyFileCompareWriter.output_category_comparison(property_files)
    property_files.property_files_by_category.each_value do |pc|
      pc.translations.each do |t|
        if !t.errors.nil?
        status = "#{t.filename} has #{t.errors.size} translation errors out of #{t.number_properties} properties"
        end
      end
    end
  end

  #Creeates a set of property file diffs which contain a list of any properties that are missing, not translated, or unknown based upon comparison with the US english property file.
  #We'll get one error file for property file language.
  def PropertyFileCompareWriter.output_language_comparison_files(property_files, output_dir)
    if !File.directory?(output_dir)
      Dir.mkdir(output_dir)
    end
    if output_dir[-1] != '/'
      output_dir = output_dir + '/' 
    end

    property_files.get_properties_organized_by_language.each do |k, v|
      File.open(output_dir + k + "_translation_errors.txt", "w:UTF-8") do |f|  
        #Insert byte order marker to indicate UTF-8
        f.puts("\uFEFF")
        v.each do |property_file|
          #If the PropertyFile instance has errors write them to the file and write each error to the file
          if !property_file.errors.nil?
            status = "#{property_file.filename} has #{property_file.errors.size} translation errors out of #{property_file.number_properties} properties"
            puts status
      
            f.puts(status)
            property_file.errors.each do |kk,vv|
              f.puts("#{kk}(#{vv[0]}): #{vv[1]}")
            end
          end
        end  
      end
    end
  end

  #Output translation errors to CSV file. The CSV file is what is sent to translators. 
  #File format is as follows  
  #Language=l
  #Header (column1:property, column2:english test, column3:translated text (not expected to be populated when generated. this is where translators fill in translated text)
  #Category=c1
  #Properties
  #Category=c2
  #Properties
  def PropertyFileCompareWriter.output_csv_translation_files(property_files, csv_dir)
    if !File.directory?(csv_dir)
      Dir.mkdir(csv_dir)
    end
    if csv_dir[-1] != '/'
      csv_dir = csv_dir + '/' 
    end
    
    property_files.get_properties_organized_by_language.each do |k, v|
      File.open(csv_dir + k + "_translation_errors.csv", "w:UTF-8") do |f|  
        #Insert byte order marker to indicate UTF-8
        f.puts("\uFEFF")
        f.puts(CSV_LANGUAGE_HEADER + k)
        f.puts(CSV_COLUMN_HEADER)
        #v is an array of PropertyFiles based on language         
        v.each do |property_file|
          if !property_file.errors.nil?
            f.puts("Category=#{property_file.category}")
            #Write errors (missing translations) to the csv file
            property_file.errors.each do |kk,vv|
              #Don't include unknown properties since we don't want these translated              
              if vv[0] != PropertyFileComparator::ERRORS[:UNKNOWN_PROPERTY]
                f.puts("\"#{kk}\",\"#{vv[1]}\"")
              end
            end
          end
        end
      end
    end
  end

  def PropertyFileCompareWriter.output_excel_translation_files(property_files, excel_dir)
    if !File.directory?(excel_dir)
      Dir.mkdir(excel_dir)
    end
    if excel_dir[-1] != '/'
      excel_dir = excel_dir + '/' 
    end
    Spreadsheet.client_encoding = 'UTF-8'    
    property_files.get_properties_organized_by_language.each do |k, v|
      write_file = false
      book = Spreadsheet::Workbook.new
      #v is an array of PropertyFiles based on language         
      v.each do |property_file|
        if !property_file.errors.nil?
          #We only want to write an output file if there are any errors found
          write_file = true
          sheet = book.create_worksheet(:name => property_file.category)
          sheet.insert_row(sheet.row_count)
          last_row = sheet.last_row 
          last_row.concat(EXCEL_COLUMN_HEADER)        
          #Write errors (missing translations) to the csv file
          property_file.errors.each do |kk,vv|
            #Don't include unknown properties since we don't want these translated              
            if vv[0] != PropertyFileComparator::ERRORS[:UNKNOWN_PROPERTY]
              sheet.insert_row(sheet.row_count)
              last_row = sheet.last_row 
              last_row.concat([kk, vv[1]])
            end
          end
        end
      end
      book.write(excel_dir + k + "_translation_errors.xls") if write_file
    end
  end
  
  #Reads a given csv translation file (as output by PropertyFileCompareWriter.output_csv_translation_files). The translated text is read and populated into an 
  #an array of PropertySets which is returned along with the language string
  #return language (string PropertyFileAttributes::Languages), property_sets (array of PropertySets, an entry for each category)
  def PropertyFileCompareWriter.read_csv_translation_files(filename)
    s = nil
    File.open(filename, "r:UTF-8") do |f|  
      s = f.read
    end
    s = PropertyFileAttributes.remove_break_space(s)
    #Split the csv file based on categories. First element is header info, subsequent elements are properties based on category
    split_by_category = s.split(CSV_CATEGORY_HEADER)
    #Remove the header
    header = split_by_category.shift

    #Language
    language = nil  
    regex = Regexp.new(CSV_LANGUAGE_HEADER + '(.*)')
    m = regex.match(header)
    if m != nil
      language = m[1]
      #Remove any commas if there are any
      language = language.gsub(",","").strip
    else
      puts "Language not found: #{filename}"
      raise EOFError
    end
    
    property_sets = [] 
    #Parse CSV for each category
    split_by_category.each do |cat|    
      csv_data = CSV.parse(cat)
      #category is the first line in the split csv
      category = csv_data[0][0].strip
      property_set = PropertySet.new(category, language)    
      #Parse thru properties and identify any properties with translations
      csv_data.each do |d|
        #Verify a translation exists before setting it to the property set
        if d.size > 2 and !d[2].nil? and d[2] != "" and d[2] != d[1]
          property_set.set_property(d[0], d[2])
        end
      end
      property_sets.push(property_set)
    end
    return language, property_sets
  end

  #Reads a given excel translation file (as output by PropertyFileCompareWriter.output_csv_translation_files). The translated text is read and populated into an 
  #an array of PropertySets which is returned along with the language string
  #return language (string PropertyFileAttributes::Languages), property_sets (array of PropertySets, an entry for each category)
  def PropertyFileCompareWriter.read_excel_translation_files(filename)
    #Find language based on filename
    language = nil
    #Find the language based on the path
    PropertyFileAttributes::LOCALES.each do |l|
      if filename.index(l)
        language = l
      end
    end
    #If the language is not indicated assume it is English
    if language == nil
      raise ArgumentError, "Unknown language for #{filename}. Filename must include locale string."
    end
    property_re = Regexp.new('.*\..*')        
    book = Spreadsheet.open(filename)    
    property_sets = []
    #Now go thru each sheet
    book.worksheets.each do |sheet|
      #Find category
      category = sheet.name
      if !PropertyFileAttributes::PROPERTY_FILE_CATEGORIES.include?(category)
        raise ArgumentError, "Unknown category(#{category} for #{filename}"
      end
      property_set = PropertySet.new(category, language)
      sheet.each do |row|
        col0 = PropertyFileAttributes.remove_break_space(row[0])
        #Cheack for property      
        if (m = property_re.match(col0))
          #Verify a translation exists before setting it to the property set
          if row.size >= 3 and !row[2].nil? and row[2] != "" and row[2] != row[1]
            property = col0
            translation = PropertyFileAttributes.remove_break_space(row[2])
            property_set.set_property(property, translation)
          end
        end
      end
      #Put this property set in our array of all sets
      property_sets.push(property_set)
    end
    
    return language, property_sets
  end
end