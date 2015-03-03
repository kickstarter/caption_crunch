require_relative './spec_helper'

describe 'CaptionCrunch' do
  describe 'parse' do
    describe 'parsing invalid input' do
      it 'should raise CaptionCrunch::ParseError' do
        assert_raises(CaptionCrunch::ParseError) do
          CaptionCrunch.parse(fixture('invalid.vtt'))
        end
      end
    end
  end
end
