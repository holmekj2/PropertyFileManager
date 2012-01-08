require 'csv'
require_relative 'property_file'

module PropertyFileCompareWriter
  def PropertyFileCompareWriter.output_category_comparison(property_files)
    property_files.property_files_by_category.each_value do |pc|
      pc.translations.each do |t|
        if !t.errors.nil?
        status = "#{t.filename} has #{t.errors.size} translation errors out of #{t.number_properties} properties"
        #puts status
        #puts "\n\n#{status}"
        #overall_status.push(status)
          #t.errors.each do |k, v|
        #  puts "#{k}(#{v[0]}): #{v[1]}"
        #end
        end
      end
    end
  end

  def PropertyFileCompareWriter.output_language_comparison_files(property_files, output_dir)
    if !File.directory?(output_dir)
      Dir.mkdir(output_dir)
    end

    property_files.get_properties_organized_by_language.each do |k, v|
      File.open(output_dir + "/" + k + "_translation_errors.txt", 'w') do |f|  
        v.each do |property_file|
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

  #Output to CSV file
  #File format is as follows
  #Language=l
  #Header
  #Category=c1
  #Properties
  #Category=c2
  #Properties
  def PropertyFileCompareWriter.output_csv_translation_files(property_files, output_dir)
    csv_dir = output_dir + '/csv/'
    if !File.directory?(csv_dir)
      Dir.mkdir(csv_dir)
    end
    header = 'Property,English Text,Translated Text'
    property_files.get_properties_organized_by_language.each do |k, v|
      File.open(csv_dir + k + "_translation_errors.csv", 'w') do |f|  
        f.puts("Language=#{k}")
        f.puts(header)  
        v.each do |property_file|
          if !property_file.errors.nil?
            f.puts("Category=#{property_file.category}")
            property_file.errors.each do |kk,vv|
              f.puts("\"#{kk}\",\"#{vv[1]}\"")
            end
          end
        end
      end
    end
  end
  
  #Reads a given csv translation file and returns an array of PropertySets
  def PropertyFileCompareWriter.read_csv_translation_files(filename)
    s = nil
    File.open(filename, 'r') do |f|  
      s = f.read
    end
    split_by_category = s.split("Category=")
    #Remove the header
    header = split_by_category.shift

    #Language
    language = nil  
    regex = /Language=(.*)/
    m = regex.match(header)
    if m != nil
      language = m[1]
    else
      puts "Language not found: #{filename}"
      raise EOFError
    end
    property_sets = [] 
    #Parse CSV for each category
    split_by_category.each do |cat|    
      csv_data = CSV.parse(cat)
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
    property_sets
  end
  
end