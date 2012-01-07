module PropertyFileCompareWriter
  def PropertyFileCompareWriter.output_category_comparison(property_files)
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

  def PropertyFileCompareWriter.output_language_comparison_files(property_files, output_dir)
    if !File.directory?(output_dir)
      Dir.mkdir(output_dir)
    end

    property_files.get_properties_organized_by_language.each do |k, v|
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

  def PropertyFileCompareWriter.output_csv_comparison_files(property_files, output_dir)
    csv_dir = output_dir + '/csv/'
    if !File.directory?(csv_dir)
      Dir.mkdir(csv_dir)
    end
    header = "Property,English Text,Translated Text"
    property_files.get_properties_organized_by_language.each do |k, v|
      File.open(csv_dir + k + "_translation_errors.csv", 'w') do |f|  
        f.puts(header)	
        v.each do |property_file|
          if !property_file.errors.nil?
            f.puts("Category: #{property_file.category}")
            property_file.errors.each do |kk,vv|
              f.puts("\"#{kk}\",\"#{vv[1]}\"")
            end
          end
        end
      end
    end
  end
end