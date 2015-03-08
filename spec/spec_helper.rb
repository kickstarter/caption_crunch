require "rubygems"
require "bundler/setup"

require "minitest/autorun"
require "minitest/pride"
require "caption_crunch"

class MiniTest::Spec
  def fixture(path)
    path = File.join(File.dirname(__FILE__), 'fixtures', path)
    File.open(path)
  end
end
