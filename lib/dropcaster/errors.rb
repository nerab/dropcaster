module Dropcaster
  class ConfigurationError < StandardError
    def initialize(msg)
      super(msg)
    end
  end

  class MissingAttributeError < ConfigurationError
    def initialize(missingAttribute)
      super("#{missingAttribute} is a mandatory channel attribute, but it is missing.")
    end
  end

  class AmbiguousSourcesError < ConfigurationError
    def initialize(ambiguousSources)
      super("The list of sources is ambiguous. Can't derive common directory from these: #{ambiguousSources.inspect}")
    end
  end

  class TemplateNotFoundError < ConfigurationError
    def initialize(message)
      super("Unable to load template file: #{message}")
    end
  end
end
