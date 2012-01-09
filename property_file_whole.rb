EMPTY = "empty"
MISSING = "missing"
NOT_TRANSLATED = "not translated"
UNKNOWN_PROPERTY = "unknown property"
PROPERTY_FILE_CATEGORIES = ["ActernaDCS", "QamPerformanceClient", "QAMTrakFlashClient", "SAFlashClient"]
LOCALES = ["US", "DE", "ES", "JP", "BR", "CN"]


nominal = parse_property_file("nominal.txt")
test = parse_property_file("test.txt")
errors = compare_against_nominal(nominal, test)
puts errors

class PropertyFiles
  attr_reader :property_files_by_category
  PROPERTY_FILE_PATTERN = "App*Resource*.properties"
  def initialize(base_directory)
    @property_files = nil
    scan_fs_for_property_files(base_directory)    
  end

  #Does recursive search started at base_directory and creates array of PropertyFile instances
  def scan_fs_for_property_files(base_directory)
    property_file_search_pattern = File.join("**", PROPERTY_FILE_PATTERN)	
	@property_filenames = Dir.glob(property_file_search_pattern)
	@property_files = []
	@property_filenames.each do |p|
	  begin
	    @property_files.push(PropertyFile.new(p))
	  rescue
	  end
	end
  end
  
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

  #Create a hash of all categories
  def organize_by_category(category)
    @property_files_by_category = Hash.new
    @property_files.each do |p|    
	  #If we don't have an instance for this category yet, create one
	  if !@property_files_by_category.has_key?(p.category)
	    @property_files_by_category[p.category] = PropertyFileCategory.new(p.category)
	  end
	  #Add the property file to the category based on whether it is in English (nominal) or a translation
	  if p.language == LOCALES[0]
	    @property_files_by_category[p.category].set_nominal(p)
	  else
	    @property_files_by_category[p.category].add_translation(p)	  
	  end
	end
  end
  
end

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

class PropertyFileComparator
  def compare_category(property_file_category)
    nominal_properties = property_file_category.nominal.get_properties
    property_file_category.translations.each do |t|
	  translation_errors = compare_against_nominal(nominal_properties, t.get_properties)
	  t.set_erros(translation_errors)
	end
  end
  
  def compare_all(property_file_categories)
  end
  
  #Compares a property set against a nominal set
  #nominal is the english properties, translation is the foreign language set to translation
  #returns a hash of properties that look to be not translated. 
  #The return hash can have a value of "empty" (not set), "missing" (no property exists), "not translated", or "unknown property" (for a property that exists in translation but not in nominal)
  def compare_against_nominal(nominal, translation)
    errors = Hash.new
    nominal.each do |k, v|
      status = nil
	  #Test for missing keys, empty strings, and untranslated strings
      if !translation.has_key?(k)
	    status = MISSING
	  elsif translation[k] == nil or translation[k] == "" or translation[k] == '""'
	    status = EMPTY
	  elsif translation[k] == nominal[k]
	    status = NOT_TRANSLATED
	  end
	  #If we have errors put them in our error hash
	  if status != nil
	    errors[k] = status
	  end
      #Now remove this entry from the translation group 
      translation.delete(k)
    end

    #Now log errors for extra properties in the translation set
    translation.each_key do |k|
      errors[k] = UNKNOWN_PROPERTY
    end
    errors
  end
end

class PropertyFile
  attr_reader :category, :language
  REGEX = /(.*)=\s?(.*)/ #Assumes PropertyName=PropertyString with or without whitespace around =
  #Creates an instance of the property file with the assigned attributes. Throws exception if there is an inconsistency
  def initialize(filename)
      @filename = filename
	  @base_filename = File.basename(f)
	  @filepath = File.dirname(f)
	  @category = nil
	  find_category(filename)
	  @language = nil
	  fine_language(filename)
	  @errors = nil
  end
  
  #Write the updated property file to disk
  def save
    #TODO
  end
  
  def write_errors
    if @errors
	  error_filename = @base_filename + ".errors"
      File.open(error_filename, 'w') do |f|  
        errors.each do |k,v|
	      f.puts("#{k} : #{v}") 
	    end
	  end
	end
  end
  
  #Finds the category of property file based on file naming scheme. Throws exception if the category is unknown or not found
  def find_category	
	#Find the property file category based on the path
	PROPERTY_FILE_CATEGORIES.each do |p|
	  if @filename.index(p)
	    @category = p
	  end
	end
	if @category == nil
	  puts "Unknown property file category: #{@filename}"
	  raise
	end
  end
  
  #Finds the language of property file based on file naming scheme. Throws exception if the language is unknown or not found  
  def find_language
    #Find the language based on the path
    LOCALES.each do |l|
	  if @filename.index(l)
	    @language = l
	  end
    end
	#If the language is not indicated assume it is English
    if @language == nil
	  @language = LOCALES[0] #"US"
    end
  end  
  #Parses a property file and returns a hash of properties with key as Property name and the value as the string for that property
  def get_properties
    #Assumes PropertyName=PropertyString with or without whitespace around =
    properties = Hash.new
    File.open(@filename).each_line do |s| 
      m = REGEX.match(s)
	  if m != nil
	    properties[m[1]] = m[2]
	  end
    end 
    properties
  end
  def set_errors(errors)
    @errors = errors
  end
end

./main/ActernaDCS/src/ApplicationResources.properties
./main/ActernaDCS/src/ApplicationResources_ja_JP.properties
./main/ActernaDCS/src/ApplicationResources_pt_BR.properties
./main/ActernaDCS/src/ApplicationResources_zh_CN.properties
./main/ActernaDCS/test/build.properties
./main/CollectionApp/config/build.properties
./main/CollectionApp/test/build.properties
./main/ConfigApp/config/build.properties
./main/ConfigApp/test/build.properties
./main/QamPerformanceClient/src/locale/de_DE/AppResource.properties
./main/QamPerformanceClient/src/locale/en_US/AppResource.properties
./main/QamPerformanceClient/src/locale/es_ES/AppResource.properties
./main/QamPerformanceClient/src/locale/ja_JP/AppResource.properties
./main/QamPerformanceClient/src/locale/pt_BR/AppResource.properties
./main/QamPerformanceClient/src/locale/zh_CN/AppResource.properties
./main/QAMTrakFlashClient/src/locale/de_DE/AppResource.properties
./main/QAMTrakFlashClient/src/locale/en_US/AppResource.properties
./main/QAMTrakFlashClient/src/locale/es_ES/AppResource.properties
./main/QAMTrakFlashClient/src/locale/ja_JP/AppResource.properties
./main/QAMTrakFlashClient/src/locale/pt_BR/AppResource.properties
./main/QAMTrakFlashClient/src/locale/zh_CN/AppResource.properties
./main/SAFlashClient/src/locale/de_DE/AppResource.properties
./main/SAFlashClient/src/locale/en_US/AppResource.properties
./main/SAFlashClient/src/locale/es_ES/AppResource.properties
./main/SAFlashClient/src/locale/ja_JP/AppResource.properties
./main/SAFlashClient/src/locale/pt_BR/AppResource.properties
./main/SAFlashClient/src/locale/zh_CN/AppResource.properties
