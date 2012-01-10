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

require_relative 'property_files'
require_relative 'property_file_comparator'
require_relative 'property_file_compare_writer'

if ARGV.size != 2
  puts "usage: property_file_patcher webview_base_dir path_file.csv"
  puts "This script takes a translation file that contains translations in csv format (as produced in the checker) and patches those translations in the appropriate files in the given base dir"
  exit
end

base_dir = ARGV[0]
patch_file = ARGV[1]

#Read the input patch file. We'll get the language and a set of instances for all the property sets (one for each category in the patch file)
language, property_sets = PropertyFileCompareWriter.read_excel_translation_files(patch_file)
if property_sets.empty?
  puts "No property founds in #{patch_file}"
  exit
end

#Create the property files manage
property_files = PropertyFiles.new(base_dir)

#For each of the property sets (i.e. category sets), apply the translations in the patch file to the real property files
property_sets.each do |ps|
  if !ps.properties.empty?
    property_file = property_files.get_property_file(ps.category, ps.language)
    if !property_file.nil?
      number_patches = property_file.patch(ps)
      if number_patches > 0 
        puts "Patched #{number_patches} properties in #{property_file.filename}"
      end
    else
      puts "Unknown language or category: #{ps.category}, #{ps.language}"
    end
  end
end
