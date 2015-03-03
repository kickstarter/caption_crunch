module CaptionCrunch
  # Delegates to Adapters::VTT.parse.
  # Returns a CaptionCrunch::Track instance
  def self.parse(file)
    Adapters::VTT.parse(file)
  end
end

require "caption_crunch/version"
require 'caption_crunch/parse_error'
require 'caption_crunch/track'
require 'caption_crunch/cue'
require 'caption_crunch/adapters'
