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

property_sets = PropertyFileCompareWriter.read_csv_translation_files(patch_file)
if property_sets.empty?
  puts "No property founds in #{patch_file}"
  exit
end

#grab language from file
language = property_sets[0].language
language.gsub!(",","")

property_files = PropertyFiles.new(base_dir)
property_sets.each do |ps|
  if !ps.properties.empty?
    property_file = property_files.get_property_file(ps.category, ps.language)
    if !property_file.nil?
      number_patches = property_file.patch(ps)
      if number_patches > 0 
        puts "Patched #{number_patches} properties in #{property_file}"
      end
    else
      puts "Unknown language or category: #{ps.category}, #{ps.language}"
    end
  end
end

#property_files = PropertyFiles.new(base_dir)
#comparator = PropertyFileComparator.new
#comparator.compare_all(property_files.property_files_by_category)
#PropertyFileCompareWriter.output_language_comparison_files(property_files, output_dir)
#PropertyFileCompareWriter.output_csv_translation_files(property_files, output_dir)
