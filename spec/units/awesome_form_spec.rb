require 'spec_helper'

describe AwesomeForm do
  describe '.setup' do
    it 'should yield self' do
      AwesomeForm.setup do |config|
        config.should equal AwesomeForm
      end
    end
  end

  describe '.register' do
    before do
      AwesomeForm.register :some_theme do |config|
        config.default_input_class = 'foo'
        config.default_actions = %i(submit cancel)
      end
    end

    it 'should register the theme config' do
      AwesomeForm.theme_configurations[:some_theme].should be_present
      AwesomeForm.theme_configurations[:some_theme].default_input_class.should eq 'foo'
      AwesomeForm.theme_configurations[:some_theme].default_actions.should eq %i(submit cancel)
    end

    context 'then selecting the configured theme' do
      before do
        AwesomeForm.setup do |config|
          config.theme = :some_theme
        end
      end

      it 'should apply the config' do
        AwesomeForm.default_input_class.should eq 'foo'
        AwesomeForm.default_actions.should eq %i(submit cancel)
      end

      context 'and selecting back the default theme' do
        before do
          AwesomeForm.setup do |config|
            config.theme = :default_theme
          end
        end

        it 'should apply the config' do
          AwesomeForm.default_input_class.should eq 'input'
          AwesomeForm.default_actions.should eq %i(submit)
        end
      end
    end
  end
end
