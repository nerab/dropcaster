class ConfigurationError < StandardError
  def initialize(msg)
    super(msg)
  end
end

class MissingAttributeError < ConfigurationError
  def initialize(missingAttribute)
    super("#{missingAttribute} is a mandatory attribute, but it is missing.")
  end
end
