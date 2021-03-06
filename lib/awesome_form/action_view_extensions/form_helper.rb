module AwesomeForm
  module ActionViewExtensions
    module FormHelper
      def awesome_form_for(object, options={}, &block)
        options[:builder] ||= AwesomeForm::FormBuilder

        form_for(object, options, &block)
      end
    end
  end
end

ActionView::Base.send :include, AwesomeForm::ActionViewExtensions::FormHelper
