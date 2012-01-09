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

require_relative 'property_ignore'

class PropertyFileComparator
  ERRORS = {:EMPTY => "empty", :MISSING => "missing", :NOT_TRANSLATED => "not translated", :UNKNOWN_PROPERTY => "unknown property"}
  
  #Compare a property files for a given category
  #property_file_category (PropertyFileCategory instance)
  def compare_category(property_file_category)
    nominal_properties = property_file_category.nominal.get_properties
    property_file_category.translations.each do |t|
      translation_errors = compare_against_nominal(nominal_properties, t.get_properties)
      t.set_errors(translation_errors)
    end
  end

  #Compare all property files
  #property_file_categories (array of PropertyFileCategory instances)
  def compare_all(property_file_categories)
    property_file_categories.each do |p|
      compare_category(p)
    end
  end
  
  #Compares a property set against a nominal set
  #nominal is the english properties, translation is the foreign language set to translation
  #return is a hash key=property, value is array [error status(PropertyFileComparator::ERRORS), text to be translated]
  def compare_against_nominal(nominal, translation)
    errors = Hash.new
    nominal.each do |k, v|
      status = nil    
      if check_for_valid_comparison(k, v)
        #Test for missing keys, empty strings, and untranslated strings
        if !translation.has_key?(k)
          status = ERRORS[:MISSING]
        elsif translation[k] == nil or translation[k] == "" or translation[k] == '""'
          status = ERRORS[:EMPTY]
        elsif translation[k] == v
          status = ERRORS[:NOT_TRANSLATED]
        end
        #If we have errors put them in our error hash
        if status != nil
          errors[k] = [status, v]
        end
      end
      #Now remove this entry from the translation group 
      translation.delete(k)
    end

    #Now log errors for extra properties in the translation set
    translation.each do |k, v|
      errors[k] = [ERRORS[:UNKNOWN_PROPERTY], v]
    end
    errors
  end
  
  private
  #Returns false if we should not try to translate this property
  def check_for_valid_comparison(property, value)
    #We want to ignore certain things for translation as defined here.
    status = !(check_for_hyperlink(value) or check_for_number(value) or check_for_hex(value) or check_for_embed(value) or check_for_ignore(property))
  end
  
  def check_for_hyperlink(s)
    #hyperlink ends in htm or html
    index = s =~ /\.html?$/
    return index != nil
  end
  
  #Returns true if s is a number
  def check_for_number(s)
    #check for number. real numbers either have . or , separators
    index = s =~ /[^-\d\.,]/ 
    return index == nil
  end
  
  def check_for_hex(s)
    index = s =~ /[^\dABCDEFabcdefxX#]/
    return index == nil
  end
  def check_for_embed(s)
    index = s =~ /^Embed/
    return index != nil
  end
  
  def check_for_ignore(property)
    PROPERTIES_TO_IGNORE.include?(property)
  end
end

