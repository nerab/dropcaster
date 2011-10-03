class ConfigurationError < StandardError
  def initialize(msg)
    super(msg)
  end
end

class MissingAttributeError < ConfigurationError
  def initialize(missingAttribute)
    super("#{missingAttribute} is a mantadory attribute, but it is missing.")
  end
end
