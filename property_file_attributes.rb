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

module PropertyFileAttributes
  #Categories represent the different property files. These categories strings are expected to be contained in the filepath.
  PROPERTY_FILE_CATEGORIES = ["ActernaDCS", "QamPerformanceClient", "QAMTrakFlashClient", "SAFlashClient"]
  #Encoding types for the various property file categories
  CATEGORY_ENCODINGS = {"ActernaDCS" => "ISO-8859-1", "QamPerformanceClient" => "UTF-8", "QAMTrakFlashClient" => "UTF-8", "SAFlashClient" => "UTF-8"}
  
  #Different languages for translations. These language strings are expected to be contained in the filepath.
  LOCALES = ["en_US", "de_DE", "es_ES", "ja_JP", "pt_BR", "zh_CN"]
  #Pattern for the property file search
  PROPERTY_FILE_PATTERN = "App*Resource*.properties"
  #Regex to parse the property files into properties and value (property=value with or without whitespace around =)
  PROPERTY_FILE_REGEX = /(.*?)=\s?(.*)/ 

  #Convert the break space that is used in some languages to a regular space
  def PropertyFileAttributes.remove_break_space(s)
    if s.encoding.name == "UTF-8"
      #First try UTF-8
      s = s.gsub("\u00A0", " ")          
    elsif s.encoding.name == "ISO-8859-1"
      #Then try latin1
      s = s.gsub("\lA0", " ")              
    end
    s
  end
  
  def PropertyFileAttributes.convert_to_utf8(s)
    s = s.encode("UTF-8")
  end  
end
