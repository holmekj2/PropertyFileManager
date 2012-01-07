require 'test/unit'
require '../property_file'

class PropertyFileTest < Test::Unit::TestCase
  def test_sa_category
    filename1 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\SAFlashClient\src\locale\de_US\AppResource.properties'
	pf = PropertyFile.new(filename1)
	assert_equal("SAFlashClient", pf.category)
  end

  def test_qamtrak_category
    filename1 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\QAMTrakFlashClient\src\locale\de_US\AppResource.properties'
	pf = PropertyFile.new(filename1)
	assert_equal("QAMTrakFlashClient", pf.category)
  end

  def test_qam_performance_category
    filename1 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\QamPerformanceClient\src\locale\de_US\AppResource.properties'
	pf = PropertyFile.new(filename1)
	assert_equal("QamPerformanceClient", pf.category)
  end

  def test_dcs_category
    filename1 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\ActernaDCS\src\ApplicationResources_pt_BR.properties'
	pf = PropertyFile.new(filename1)
	assert_equal("ActernaDCS", pf.category)
  end

  def test_english_language
    filename1 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\ActernaDCS\src\ApplicationResources.properties'
	pf = PropertyFile.new(filename1)
	assert_equal("US", pf.language)
    filename2 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\SAFlashClient\src\locale\en_US\AppResource.properties'
	pf = PropertyFile.new(filename2)
	assert_equal("US", pf.language)
  end
  
  def test_brazil_language
    filename1 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\ActernaDCS\src\ApplicationResources_pt_BR.properties'
	pf = PropertyFile.new(filename1)
	assert_equal("BR", pf.language)
    filename2 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\SAFlashClient\src\locale\de_BR\AppResource.properties'
	pf = PropertyFile.new(filename2)
	assert_equal("BR", pf.language)
  end

  def test_chinese_language
    filename1 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\ActernaDCS\src\ApplicationResources_zh_CN.properties'
	pf = PropertyFile.new(filename1)
	assert_equal("CN", pf.language)
    filename2 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\SAFlashClient\src\locale\zh_CN\AppResource.properties'
	pf = PropertyFile.new(filename2)
	assert_equal("CN", pf.language)
  end

  def test_japanese_language
    filename1 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\ActernaDCS\src\ApplicationResources_ja_JP.properties'
	pf = PropertyFile.new(filename1)
	assert_equal("JP", pf.language)
    filename2 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\SAFlashClient\src\locale\ja_JP\AppResource.properties'
	pf = PropertyFile.new(filename2)
	assert_equal("JP", pf.language)
  end

  def test_spanish_language
    filename1 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\ActernaDCS\src\ApplicationResources_es_ES.properties'
	pf = PropertyFile.new(filename1)
	assert_equal("ES", pf.language)
    filename2 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\SAFlashClient\src\locale\es_ES\AppResource.properties'
	pf = PropertyFile.new(filename2)
	assert_equal("ES", pf.language)
  end

  def test_german_language
    filename1 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\ActernaDCS\src\ApplicationResources_de_DE.properties'
	pf = PropertyFile.new(filename1)
	assert_equal("DE", pf.language)
    filename2 = 'C:\Users\hol48987\Documents\home\hol48987_D6KWQM1\PathTrak\SystemSoftware\WebView\main\SAFlashClient\src\locale\de_DE\AppResource.properties'
	pf = PropertyFile.new(filename2)
	assert_equal("DE", pf.language)
  end
  
  #filename2 = './main/ActernaDCS/src/ApplicationResources.properties'
end