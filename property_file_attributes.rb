module PropertyFileAttributes
  #Categories represent the different property files. These categories strings are expected to be contained in the filepath.
  PROPERTY_FILE_CATEGORIES = ["ActernaDCS", "QamPerformanceClient", "QAMTrakFlashClient", "SAFlashClient"]
  #Different languages for translations. These language strings are expected to be contained in the filepath.
  LANGUAGES = ["US", "DE", "ES", "JP", "BR", "CN"]
  #Pattern for the property file search
  PROPERTY_FILE_PATTERN = "App*Resource*.properties"
  PROPERTY_FILE_REGEX = /(.*?)=\s?(.*)/ #Assumes PropertyName=PropertyString with or without whitespace around =
end
