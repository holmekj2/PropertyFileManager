require 'test/unit'
require '../property_file_comparator'
require '../property_file'

class PropertyFilseTest < Test::Unit::TestCase
  #Test that the file scanning for files is correct. The test directory should include a hierarchy with all files in the TEST_PROPERTY_FILES list
  def test_comparison
    nominal = PropertyFile.new("testfile_ActernaDCS_ApplicationResources.properties")
	test = PropertyFile.new("testfile_ActernaDCS_ApplicationResources_ja_JP.properties")
	comparator = PropertyFileComparator.new
	errors = comparator.compare_against_nominal(nominal.get_properties, test.get_properties)
	expected_errors = {"property2"=>"not translated", "property3"=>"empty", "property4"=>"empty", "propety5"=>"unknown property"}
	assert_equal(expected_errors, errors)
  end
end