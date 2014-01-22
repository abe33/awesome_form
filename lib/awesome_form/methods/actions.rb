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
        action_options = {
          action: action.to_sym,
          object_name: object_name,
          object: object,
          model_name: model_name,
          resource_name: resource_name,
          builder: self,
        }

        case action.to_sym
        when :submit then action_options[:name] = :commit
        when :cancel then action_options[:name] = :cancel
        when :reset then action_options[:name] = :reset
        end

        action_options.merge(options)
      end

      def default_actions_content(options)
        ''
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
          "awesome_form/actions/#{resource_name}/#{action}",
          "awesome_form/#{theme}/actions/#{resource_name}/#{action}",

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
          "awesome_form/wrappers/#{resource_name}/#{action}",
          "awesome_form/#{theme}/wrappers/#{resource_name}/#{action}",

          "awesome_form/wrappers/#{action}",
          "awesome_form/#{theme}/wrappers/#{action}",
          "awesome_form/default_theme/wrappers/#{action}"
        ].uniq
      end
    end
  end
end
