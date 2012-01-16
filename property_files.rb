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

require_relative 'property_file'
require_relative 'property_file_attributes'


#Class to sort PropertyFile instances based on PropertyFileAttributes::PROPERTY_FILE_CATEGORY
class PropertyFileCategory
  attr_reader :nominal, :translations, :category
  #category (PropertyFileAttributes::PROPERTY_FILE_CATEGORY)
  def initialize(category)
    @category = category
    @nominal = nil
    @translations = []
  end
  
  #Add a PropertyFile instance of a translation file
  def add_property_file(property_file)
    #Determine if this is the default or translation file
    if property_file.filename =~ PropertyFileAttributes::DEFAULT_TRANSLATION[@category]
      @nominal = property_file
    else
      translations.push(property_file)
    end
  end
end

#Property file manager
class PropertyFiles
  #property_files_by_category (hash of categories, key=PropertyFileAttributes::PROPERTY_FILE_CATEGORY, values are all instances of PropertyFileCategory for each detected category)
  #property_filenames (array of strings of all located property filenames)
  attr_reader :property_files_by_category, :property_filenames  
  #Initialize the manager. base_directory indicates the directory to start the recursive search for property files
  def initialize(base_directory)
    @property_files = nil
    scan_fs_for_property_files(base_directory)    
    organize_by_category
  end
  
  #Get a PropertyFile instance by category and language
  #category PropertyFileAttributes::PROPERTY_FILE_CATEGORY
  #language PropertyFileAttributes::LANGUAGE
  def get_property_file(category, language)
    property_file = nil
    @property_files.each do |p|
      if p.category == category and p.language == language
        property_file = p
        break
      end
    end
    property_file
  end
  
  #Get an array of PropertyFile instances for all files associated with given language
  #language PropertyFileAttributes::LANGUAGE  
  def get_properties(language)
    property_files = []
    @property_files.each do |p|
    if p.language == language
      property_files.push[p]
      break
      end
    end
    property_files
  end

  #Returns a hash of all PropertyFile instances keyed by languages.
  #Hash keys are PropertyFileAttributes::LANGUAGE, values are arrays of PropertyFile instances for that language
  def get_properties_organized_by_language
    #Create a hash
    property_files = {}
    PropertyFileAttributes::LOCALES.each do |l|
      property_files[l] = []
    end
    @property_files.each do |p|
      property_files[p.language].push(p)
    end
    #Sort the file arrays based on the filenames
    property_files.each_value do |v|
      v.sort!{|x,y| x.filename <=> y.filename}
    end
    property_files
  end
  
  #Returns a hash of all PropertyFile instances by category.
  #Create a hash of all categories. Keys are PropertyFileAttributes::PROPERTY_FILE_CATEGORY, values are instances of PropertyFileCategory.
  def organize_by_category
    @property_files_by_category = Hash.new
    @property_files.each do |p|    
      #If we don't have an instance for this category yet, create one
      if !@property_files_by_category.has_key?(p.category)
        @property_files_by_category[p.category] = PropertyFileCategory.new(p.category)
      end
      #Add the property file to the category based on whether it is in English (nominal) or a translation
      @property_files_by_category[p.category].add_property_file(p)    
    end
  end
  
  private
  #Does recursive file search started at base_directory and creates array of PropertyFile instances
  #filename scanning is defined in PropertyFileAttributes
  def scan_fs_for_property_files(base_directory)
    property_file_search_pattern = File.join("#{base_directory}/**", PropertyFileAttributes::PROPERTY_FILE_PATTERN)  
    @property_filenames = Dir.glob(property_file_search_pattern)
    @property_files = []
    @property_filenames.each do |p|
      begin
        @property_files.push(PropertyFile.new(p))
      rescue
      end
    end
  end
end

