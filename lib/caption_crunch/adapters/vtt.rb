module CaptionCrunch
  module Adapters
    class VTT
      SIGNATURE_REGEX = /\AWEBVTT\Z|\AWEBVTT[ \t\n]/.freeze
      COMMENT_REGEX   = /\ANOTE\Z|\ANOTE[ \t\n]/.freeze
      ARROW_REGEX     = /-->/.freeze
      # Format: hour:minute:second.milliseconds
      #         hour: is optional.
      #         11:22:33
      #         00:11:22:333
      #         102:01:43:204
      # http://dev.w3.org/html5/webvtt/#dfn-collect-a-webvtt-timestamp
      TIME_REGEX      = /\A(?:(\d\d+):)?([0-5]\d):([0-5]\d)\.(\d\d\d)\Z/.freeze
      NEWLINE_REGEX   = /\r?\n/.freeze

      class << self
        # Reads a file (or string) and returns a CaptionCrunch::Track instance.
        # Raises CaptionCrunch::ParseError if the input is malformed.
        def parse(file)
          contents = remove_bom(read_file(file))
          normalized = normalize_linefeeds(contents)
          segments = split_segments(normalized)
          ensure_signature(segments.shift)

          Track.new.tap do |track|
            segments.each do |segment|
              next if comment?(segment)
              track.cues << parse_cue(segment)
            end
          end
        end

        protected

        # Returns a string corresponding to the contents of a File instance.
        # Alternatively, if the argument is not a File, simply calls `.to_s`.
        def read_file(file)
          contents = if file.respond_to?(:read)
            file.read
          else
            file.to_s
          end

          raise ParseError, "Invalid encoding" unless contents.valid_encoding?

          contents.strip
        end

        def remove_bom(string)
          if string[0] == "\uFEFF"
            string.slice(1..-1)
          else
            string
          end
        end

        def normalize_linefeeds(string)
          string.encode(string.encoding, universal_newline: true)
        end

        # The WebVTT spec separates segments by two newlines or more.
        def split_segments(string)
          string.split(/#{NEWLINE_REGEX}{2,}/)
        end

        def ensure_signature(segment)
          if segment !~ SIGNATURE_REGEX
            raise ParseError, 'File must start with WEBVTT'
          end
        end

        def comment?(segment)
          segment =~ COMMENT_REGEX
        end

        # Turns a segment into a new CaptionCrunch::Cue instance.
        def parse_cue(segment)
          parts = segment.split(NEWLINE_REGEX)
          # ignore optional identifier for now
          parts.shift unless parts[0] =~ ARROW_REGEX
          start_time, end_time = parse_times(segment, parts)

          Cue.new.tap do |cue|
            cue.start_time = parse_time(start_time)
            cue.end_time = parse_time(end_time)
            cue.payload = parse_payload(parts)
          end
        end

        def parse_times(segment, parts)
          times = parts.shift.to_s.split(ARROW_REGEX)
          raise ParseError, "Cue timings missing: #{segment}" if times.size != 2
          start_time = times.first.strip
          # ignore settings for now
          end_time, settings = times.last.strip.split(/\s+/, 2)
          [start_time, end_time]
        end

        def parse_payload(parts)
          parts.map(&:strip).join("\n")
        end

        # Converts a timestamp into an integer representing the milliseconds.
        def parse_time(timestamp)
          match = TIME_REGEX.match(timestamp.strip)
          raise ParseError, "Invalid timestamp: #{timestamp}" unless match
          milliseconds_from_captures(match.captures.reverse)
        end

        # The elements in +captures+ should match the order of the scalars,
        # which are the ratio between a single millisecond and each unit.
        def milliseconds_from_captures(captures)
          msecs, secs, mins, hours = 1, 1000, 1000 * 60, 1000 * 60 * 60
          iterator = [msecs, secs, mins, hours].each_with_index
          iterator.map{ |scalar, i| scalar * captures[i].to_i }.reduce(:+)
        end
      end
    end
  end
end
