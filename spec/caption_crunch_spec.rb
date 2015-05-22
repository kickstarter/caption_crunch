require_relative './spec_helper'

describe 'CaptionCrunch' do
  describe 'parse' do
    describe 'parsing entirely wrong signature' do
      it 'should raise CaptionCrunch::ParseError' do
        error = ->{
          CaptionCrunch.parse('SPIDERWEBVTT')
        }.must_raise CaptionCrunch::ParseError
        error.message.must_match /File must start with WEBVTT/
      end
    end

    describe 'parsing valid signature' do
      it 'should not raise CaptionCrunch::ParseError' do
        CaptionCrunch.parse("WEBVTT\t-- here is some stuff")
      end
    end

    describe 'parsing signature starting with WEBVTT but no space after' do
      it 'should raise CaptionCrunch::ParseError' do
        error = ->{
          CaptionCrunch.parse('WEBVTTINVALID')
        }.must_raise CaptionCrunch::ParseError
        error.message.must_match /File must start with WEBVTT/
      end
    end

    describe 'parsing signature starting and ending with WEBVTT' do
      it 'should not raise CaptionCrunch::ParseError' do
        CaptionCrunch.parse('WEBVTT')
      end
    end

    describe 'parsing signature with a BOM' do
      it 'should not raise CaptionCrunch::ParseError' do
        CaptionCrunch.parse("\uFEFFWEBVTT")
      end
    end

    describe 'parsing a binary file' do
      it 'should raise a ParseError' do
        error = ->{
          CaptionCrunch.parse(fixture('binary.jpg'))
        }.must_raise CaptionCrunch::ParseError
        error.message.must_match /Invalid encoding/
      end
    end

    describe 'parsing a track with three cues' do
      subject { CaptionCrunch.parse(fixture('three_cues.vtt')) }
      it 'should return an object with three cues' do
        subject.cues.size.must_equal(3)
      end

      it 'should parse cue start times' do
        start_time = 1 * 60 * 60 * 1000 + 2 * 60 * 1000 + 25 * 1000 + 500
        subject.cues.last.start_time.must_equal(start_time)
      end

      it 'should parse cue end times' do
        subject.cues.first.end_time.must_equal(2000)
      end

      it 'should parse cue end times with >=100 hours' do
        end_time = 201 * 60 * 60 * 1000 + 3 * 60 * 1000 + 15 * 1000
        subject.cues.last.end_time.must_equal(end_time)
      end

      it 'should parse cue end times with settings after' do
        end_time = 15 * 1000
        subject.cues[1].end_time.must_equal(end_time)
      end

      it 'should parse cue payloads' do
        subject.cues.last.payload.must_equal('TTYL.')
      end

      it 'should support multi-line cue payloads' do
        subject.cues[1].payload.must_equal(%Q{
- I don't like shrimp, but I like ramen. All kinds of ramen. Miso ramen, tonkotsu ramen, shoyu ramen, Totto ramen...
- That's nice.
        }.strip)
      end
    end

    describe 'parsing cue with invalid minutes' do
      it 'should raise CaptionCrunch::ParseError' do
        error = ->{
          CaptionCrunch.parse(%Q{WEBVTT

            00:60:00.000 --> 01:02:00.000
            I'm invalid!
          })
        }.must_raise CaptionCrunch::ParseError
        error.message.must_match /Invalid timestamp/
      end
    end

    describe 'parsing cue without timings' do
      it 'should raise CaptionCrunch::ParseError' do
        error = ->{
          CaptionCrunch.parse(%Q{WEBVTT

            I'm invalid!
            Woot!
          })
        }.must_raise CaptionCrunch::ParseError
        error.message.must_match /Cue timings missing/
      end
    end

    describe 'parsing cue with invalid seconds' do
      it 'should raise CaptionCrunch::ParseError' do
        error = ->{
          CaptionCrunch.parse(%Q{WEBVTT

            00:00:60.000 --> 01:02:00.000
            I'm invalid!
          })
        }.must_raise CaptionCrunch::ParseError
        error.message.must_match /Invalid timestamp/
      end
    end

    describe 'parsing cue with invalid milliseconds' do
      it 'should raise CaptionCrunch::ParseError' do
        error = ->{
          CaptionCrunch.parse(%Q{WEBVTT

            00:00:00.1000 --> 01:02:00.000
            I'm invalid!
          })
        }.must_raise CaptionCrunch::ParseError
        error.message.must_match /Invalid timestamp/
      end
    end

    describe 'parsing cue with Windows-style line-endings' do
      subject do
        contents = "WEBVTT\r\n\r\n00:00:00.000 --> 00:00:02.000\r\nI work!"
        CaptionCrunch.parse(contents)
      end

      it 'should parse correctly' do
        subject.cues.count.must_equal 1
        subject.cues.first.payload.must_equal "I work!"
      end
    end

  end
end
