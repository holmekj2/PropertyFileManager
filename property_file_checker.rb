require_relative 'property_files'
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
comparator.compare_all(property_files.property_files_by_category)
PropertyFileCompareWriter.output_language_comparison_files(property_files, output_dir)
PropertyFileCompareWriter.output_csv_comparison_files(property_files, output_dir)
