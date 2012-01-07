PROPERTY_FILE_CATEGORIES = ["ActernaDCS", "QamPerformanceClient", "QAMTrakFlashClient", "SAFlashClient"]
LANGUAGES = ["US", "DE", "ES", "JP", "BR", "CN"]

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
    File.open(@filename).each_line do |s| 
      m = REGEX.match(s)
	  if m != nil
	    property = m[1]
		#This is a hack to get rid of the unicode non-break space that sometimes find their way into international files
        property.gsub!("\u00A0", "")				
		property.strip!
		value = m[2]
		value.gsub!("\u00A0", "")		
		value.strip!
	    properties[property] = value
	  end
    end 
	@number_properties = properties.size
    properties
  end
  def set_errors(errors)
    @errors = errors
  end

end

