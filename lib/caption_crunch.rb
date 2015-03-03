require "caption_crunch/version"

module CaptionCrunch
  autoload :ParseError, 'caption_crunch/parse_error'

  def self.parse(file)
    raise CaptionCrunch::ParseError
  end
end
