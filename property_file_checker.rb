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

require_relative 'property_file_comparator'
require_relative 'property_file_compare_writer'

if ARGV.size == 0
  puts "usage: property_file_checker webview_base_dir [output_dir]"
  exit
end

base_dir = ARGV[0]

output_dir = "./compare"
if ARGV.size == 2
  output_dir = ARGV[1]
end

property_files = PropertyFiles.new(base_dir)
#property_files = PropertyFiles.new('C:/Users/hol48987/Documents/home/hol48987_D6KWQM1/PathTrak/SystemSoftware/WebView/WebView3.0/')
comparator = PropertyFileComparator.new
comparator.compare_all(property_files.property_files_by_category.values)
PropertyFileCompareWriter.output_language_comparison_files(property_files, output_dir)
PropertyFileCompareWriter.output_csv_translation_files(property_files, output_dir)
