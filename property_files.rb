require_relative 'property_file'

class PropertyFileCategory
  attr_reader :nominal, :translations
  def initialize(category)
    @category = category
    @nominal = nil
    @translations = []
  end
  
  def set_nominal(nominal)
    @nominal = nominal
  end
  
  def add_translation(translation)
    @translations.push(translation)
  end
end

class PropertyFiles
  #property_files_by_category
  #Keys are category name, values are instances of PropertyFileCategory
  #property_filenames
  #Array of filenames of all property files
  attr_reader :property_files_by_category, :property_filenames  
  def initialize(base_directory)
    @property_files = nil
    scan_fs_for_property_files(base_directory)    
    organize_by_category
  end
  
  #Get a property file by category and language
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

  #Returns a hash of property files keyed by languages.
  #Hash keys are language (e.g. CN), values are arrays of PropertyFile instances for that language
  def get_properties_organized_by_language
    #Create a hash
    property_files = {}
    PropertyFileAttributes::LANGUAGES.each do |l|
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
  
  #Create a hash of all categories. Keys are category name, values are instances of PropertyFileCategory.
  def organize_by_category
    @property_files_by_category = Hash.new
    @property_files.each do |p|    
      #If we don't have an instance for this category yet, create one
      if !@property_files_by_category.has_key?(p.category)
        @property_files_by_category[p.category] = PropertyFileCategory.new(p.category)
      end
      #Add the property file to the category based on whether it is in English (nominal) or a translation
      if p.language == PropertyFileAttributes::LANGUAGES[0]
        @property_files_by_category[p.category].set_nominal(p)
      else
        @property_files_by_category[p.category].add_translation(p)    
      end
    end
  end
  
  #Does recursive search started at base_directory and creates array of PropertyFile instances
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

