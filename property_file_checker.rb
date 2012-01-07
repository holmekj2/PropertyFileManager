require_relative 'property_files'
require_relative 'property_file_comparator'

def output_category_comparison(property_files)
  property_files.property_files_by_category.each_value do |pc|
    pc.translations.each do |t|
      if !t.errors.nil?
	    status = "#{t.filename} has #{t.errors.size} translation errors out of #{t.number_properties} properties"
	    #puts status
	    #puts "\n\n#{status}"
	    #overall_status.push(status)
        #t.errors.each do |k, v|
	    #  puts "#{k}(#{v[0]}): #{v[1]}"
	    #end
      end
    end
  end
end

def output_language_comparison_files(property_files, output_dir)
  property_files.get_properties_organized_by_language.each do |k, v|
    if !File.directory?(output_dir)
      Dir.mkdir(output_dir)
    end
    File.open(output_dir + "/" + k + "_translation_errors.txt", 'w') do |f|  
      v.each do |property_file|
        if !property_file.errors.nil?
	      status = "#{property_file.filename} has #{property_file.errors.size} translation errors out of #{property_file.number_properties} properties"
    	  puts status
		
		  f.puts(status)
		  property_file.errors.each do |kk,vv|
		    f.puts("#{kk}(#{vv[0]}): #{vv[1]}")
		  end
        end	
      end
	end
  end
end

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
output_language_comparison_files(property_files, output_dir)
