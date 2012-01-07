require 'test/unit'
require '../property_files'

TEST_PROPERTY_FILES = [
"ActernaDCS/ApplicationResources.properties",
"ActernaDCS/ApplicationResources_ja_JP.properties",
"ActernaDCS/ApplicationResources_pt_BR.properties",
"ActernaDCS/ApplicationResources_zh_CN.properties",
"SAFlashClient/de_DE/AppResource.properties",
"SAFlashClient/en_US/AppResource.properties",
"SAFlashClient/es_ES/AppResource.properties",
"SAFlashClient/ja_JP/AppResource.properties",
"SAFlashClient/pt_BR/AppResource.properties",
"SAFlashClient/zh_CN/AppResource.properties"]

TEST_PROPERTY_CATEGORIES = 
{"ActernaDCS" => [
"ActernaDCS/ApplicationResources.properties",
"ActernaDCS/ApplicationResources_ja_JP.properties",
"ActernaDCS/ApplicationResources_pt_BR.properties",
"ActernaDCS/ApplicationResources_zh_CN.properties"],
 
"SAFlashClient" => [
"SAFlashClient/en_US/AppResource.properties",
"SAFlashClient/de_DE/AppResource.properties",
"SAFlashClient/es_ES/AppResource.properties",
"SAFlashClient/ja_JP/AppResource.properties",
"SAFlashClient/pt_BR/AppResource.properties",
"SAFlashClient/zh_CN/AppResource.properties"]}

class PropertyFilseTest < Test::Unit::TestCase
  def setup
    basedir = '.'
	@property_files = PropertyFiles.new(basedir)
  end
  
  #Test that the file scanning for files is correct. The test directory should include a hierarchy with all files in the TEST_PROPERTY_FILES list
  def test_file_scan
	assert_equal(TEST_PROPERTY_FILES.size, @property_files.property_filenames.size)
	TEST_PROPERTY_FILES.each do |f|
      assert(@property_files.property_filenames.include?(f))	
	end
  end
  
  def test_categories  
    cat = @property_files.property_files_by_category
	assert(cat.has_key?("ActernaDCS"))
	acterna_dcs = cat["ActernaDCS"]
	assert_equal("ActernaDCS/ApplicationResources.properties", acterna_dcs.nominal.filename)
	assert_equal(TEST_PROPERTY_CATEGORIES["ActernaDCS"].size - 1, acterna_dcs.translations.size)
	acterna_dcs.translations.each do |t|
	  assert(TEST_PROPERTY_CATEGORIES["ActernaDCS"].include?(t.filename))
	end
	assert(cat.has_key?("SAFlashClient"))	
	sa = cat["SAFlashClient"]
	assert_equal("SAFlashClient/en_US/AppResource.properties", sa.nominal.filename)
	assert_equal(TEST_PROPERTY_CATEGORIES["SAFlashClient"].size - 1, sa.translations.size)
	sa.translations.each do |t|
	  assert(TEST_PROPERTY_CATEGORIES["SAFlashClient"].include?(t.filename))
	end
  end  
end