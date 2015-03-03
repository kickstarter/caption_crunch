require_relative './spec_helper'

describe 'CaptionCrunch' do
  describe 'parse' do
    describe 'parsing entirely wrong signature' do
      it 'should raise CaptionCrunch::ParseError' do
        assert_raises(CaptionCrunch::ParseError) do
          CaptionCrunch.parse('SPIDERWEBVTT')
        end
      end
    end

    describe 'parsing valid signature' do
      it 'should not raise CaptionCrunch::ParseError' do
        CaptionCrunch.parse("WEBVTT\t-- here is some stuff")
      end
    end

    describe 'parsing signature starting with WEBVTT but no space after' do
      it 'should raise CaptionCrunch::ParseError' do
        assert_raises(CaptionCrunch::ParseError) do
          CaptionCrunch.parse('WEBVTTINVALID')
        end
      end
    end

    describe 'parsing signature starting and ending with WEBVTT' do
      it 'should not raise CaptionCrunch::ParseError' do
        CaptionCrunch.parse('WEBVTT')
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

      it 'should parse cue end times with settings after' do
        end_time = 1 * 60 * 60 * 1000 + 3 * 60 * 1000 + 15 * 1000
        subject.cues.last.end_time.must_equal(end_time)
      end

      it 'should parse cue payloads' do
        subject.cues.last.payload.must_equal('TTYL.')
      end
    end
  end
end
