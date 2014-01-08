require 'spec_helper'

describe AwesomeForm do
  describe '.setup' do
    it 'should yield self' do
      AwesomeForm.setup do |config|
        config.should equal AwesomeForm
      end
    end
  end
end
