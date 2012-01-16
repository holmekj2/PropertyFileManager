Usage
-----
property_file_checker.rb script provide a mechanism to parse through a set of properties files and identify which properties require 
translations (i.e. translation errors). These translation errors are then written to a Excel file which can be used
by translators to insert translations. Once the Excel files have translations that we wish to patch, the property_file_patcher.rb 
script applies the translations into the appropriate property files. 

The following shows how to use the scripts. First, we do the check which creates the xls files (in ./compare/). The input to the script
is the base directory of the Webview source code. There is one xls file
created per language. The xls file is broken down into sheets which map to the different property file types 
(e.g. SAFlashClient, QamPerformanceClient). Once the xls files are sent to the translators and sent back, we apply the translations with the 
property_file_patcher.rb script. The inputs to this are the base directory of the Webview source (this is where the translations will be applied) 
and the translation xls file. We can verify the patch by running the checker again. 

ruby property_file_checker.rb "C:/Users/hol48987/Documents/home/hol48987_D6KWQM1/PathTrak/SystemSoftware/WebView/main/" 
ruby property_file_patcher.rb "C:/Users/hol48987/Documents/home/hol48987_D6KWQM1/PathTrak/SystemSoftware/WebView/main/" "C:\Users\hol48987\Documents\workspace\ruby\PropertyFileStatus\compare\BR_translation_errors.xls"
ruby property_file_checker.rb "C:/Users/hol48987/Documents/home/hol48987_D6KWQM1/PathTrak/SystemSoftware/WebView/main/" 

Notes
-----
I used Excel files instead of text files in order to preserve UTF-8 when the translator saves the file. Excel is pretty bad with encodings and csv. 

Development notes
-----------------
The PropertyFiles class is used to search the base directory for all property files. It uses the PropertyFileAttributes::PROPERTY_FILE_PATTERN pattern as
the search statement. It then creates a PropertyFile instance for each property file found. 

The PropertyFile class parses the filename for the category and lanugage and the file for properties. The categories and language can be adjusted via
PropertyFileAttributes::PROPERTY_FILE_CATEGORIES and PropertyFileAttributes::LANGUAGE. Also the property files are expected to be in the format property=value but this
can be changed via PropertyFileAttributes::PROPERTY_FILE_REGEX.

For any properties that you wish to ignore, add them to the property_ignore.rb PROPERTIES_TO_IGNORE array. This is used for properties that don't require translations (e.g. units). 

These scripts should be used with Ruby 1.9.1+ due to the fact that they take into account Ruby 1.9 hashes are sorted based on insertion order. If you want to use it on 1.8 you will find when patching properties
the order of the properties are not going to be the same. This makes it very hard to do a before/after compare using a diff tool. You can fix it to work with 1.8 but you'll need to keep the property hash sorted in
PropertyFile.getProperties. 

Installation
------------
* Ruby Installation
For Windows use this site for an easy installation. http://rubyinstaller.org/
On Linux make sure you have 1.9.x.

* Gems
The spreadsheet gem is required to write/read Excel format. The gem is included in this package and can be installed via 'gem install spreadsheet-0.6.5.9.gem'

After that just run the scripts as described in the usage section. 

Procedure
---------
* Check out latest source from Perforce
* Run property_file_checker.
* Send output files (xls) to translators (in compare directory below working directory) 
* Run property_file_parser on files received from translator
* Diff property files and verify patches
* Check property files into Perforce

