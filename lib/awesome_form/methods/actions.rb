require 'awesome_form/methods/rendering'

module AwesomeForm
  module Methods
    module Actions
      extend AwesomeForm::Methods::Rendering

      render_method :action

    protected

      def default_keys_for_actions
        AwesomeForm.default_actions
      end

      def options_for_action(action, options)
        options = {
          action: action.to_sym,
          object_name: object_name,
          object: object,
          builder: self
        }

        case action.to_sym
        when :submit then options[:name] = :commit
        when :cancel then options[:name] = :cancel
        when :reset then options[:name] = :reset
        end

        options.merge(options)
      end

      def partial_for_action(action_options)
        partial_paths_for_action(action_options).select { |p| view_exists? p }.first
      end


      def wrapper_for_action(action_options)
        partial_paths_for_action_wrapper(action_options).select { |p| view_exists? p }.first
      end

      def partial_paths_for_action(action_options)
        theme = AwesomeForm.theme
        action = action_options[:action]

        [
          "awesome_form/actions/#{model_name}/#{action}",
          "awesome_form/#{theme}/actions/#{model_name}/#{action}",

          "awesome_form/actions/#{action}",
          "awesome_form/#{theme}/actions/#{action}",
          "awesome_form/default_theme/actions/#{action}",

          "awesome_form/actions/default",
          "awesome_form/#{theme}/actions/default",
          "awesome_form/default_theme/actions/default"
        ].uniq
      end

      def partial_paths_for_action_wrapper(action_options)
        theme = AwesomeForm.theme
        action = action_options[:action]

        [
          "awesome_form/wrappers/#{model_name}/#{action}",
          "awesome_form/#{theme}/wrappers/#{model_name}/#{action}",

          "awesome_form/wrappers/#{action}",
          "awesome_form/#{theme}/wrappers/#{action}",
          "awesome_form/default_theme/wrappers/#{action}"
        ].uniq
      end
    end
  end
end
