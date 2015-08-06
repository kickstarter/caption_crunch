# CaptionCrunch

[![Gem Version](https://badge.fury.io/rb/caption_crunch.svg)](http://badge.fury.io/rb/caption_crunch) [![Circle CI](https://circleci.com/gh/kickstarter/caption_crunch/tree/master.svg?style=shield)](https://circleci.com/gh/kickstarter/caption_crunch/tree/master)

Praise @noopkat for the name.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'caption_crunch'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install caption_crunch

## Usage

```ruby
require 'caption_crunch'
track = CaptionCrunch.parse(File.new('sample.vtt')) # returns a CaptionCrunch::Track instance
# or
track = CaptionCrunch.parse('WEBVTT')

# track.cues is an array of CaptionCrunch::Cue instances
track.cues.first.start_time
track.cues.first.end_time
track.cues.first.payload
```

## Contributing

1. Fork it ( https://github.com/kickstarter/caption_crunch/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
