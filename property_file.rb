PROPERTY_FILE_CATEGORIES = ["ActernaDCS", "QamPerformanceClient", "QAMTrakFlashClient", "SAFlashClient"]
LANGUAGES = ["US", "DE", "ES", "JP", "BR", "CN"]

class PropertySet
  attr_accessor :category, :language
  attr_reader :properties
  def initialize(category, language)
    @category = category
    @language = language
    @properties = {}
  end
  def set_property(name, text)
    @properties[name] = text
  end
end

class PropertyFile
  attr_reader :category, :language, :filename, :errors, :number_properties
  #Search for the property (prior to 1st =) and text (after the first =). 
  #The first question mark is to make the match non-greedy so that we match on the 1st instance of = otherwise we'll match on the last instance
  REGEX = /(.*?)=\s?(.*)/ #Assumes PropertyName=PropertyString with or without whitespace around =
  #Creates an instance of the property file with the assigned attributes. Throws exception if there is an inconsistency
  def initialize(filename)
    @filename = filename
    @base_filename = File.basename(filename)
    @filepath = File.dirname(filename)
    @category = nil
    find_category
    @language = nil
    find_language
    @errors = nil
    @number_properties = nil
  end
  
  #Patch the current property file with updated from the given patch_property_set
  #Returns the number of patches applied
  def patch(patch_property_set)
    number_patches_applied = 0
    properties = get_properties
    patch_property_set.properties.each do |patch_properties_key, patch_properties_value|
      if properties.has_key?(patch_properties_key)
        if patch_properties_value != properties[patch_properties_key] 
          properties[patch_properties_key] = patch_properties_value
          number_patches_applied += 1
        end
      else
        puts "Unknown property from patch #{patch_properties_key} in #{@filename}"
      end
    end
    save(properties)
    number_patches_applied
  end
  
  #Overwrite the current file with the given set of properties
  def save(properties)
    File.open(@filename, 'w') do |f| 
      properties.each do |k,v|
        f.puts("#{k}=#{v}")
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
    LANGUAGES.each do |l|
      if @filename.index(l)
        @language = l
      end
    end
    #If the language is not indicated assume it is English
    if @language == nil
      @language = LANGUAGES[0] #"US"
    end
  end  
  
  #Parses a property file and returns a hash of properties with key as Property name and the value as the string for that property
  def get_properties
    #Assumes PropertyName=PropertyString with or without whitespace around =
    properties = Hash.new
    File.open(@filename, 'r').each_line do |s| 
      m = REGEX.match(s)
      if m != nil
        property = m[1]
        #This is a hack to get rid of the unicode non-break space that sometimes find their way into international files
        property = remove_break_space(property).strip()        
        value = m[2]
        value = remove_break_space(value).strip()
        properties[property] = value
      end
    end 
    @number_properties = properties.size
    properties
  end

  #Convert the break space that is used in some languages to a regular space
  def remove_break_space(s)
    s.gsub("\u00A0", " ")          
  end
  
  def set_errors(errors)
    @errors = errors
  end

end

