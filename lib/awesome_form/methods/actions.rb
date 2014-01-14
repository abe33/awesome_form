module AwesomeForm
  module Methods
    module Actions

      def actions(*args, &block)
        actions, options = filter_arguments(*args)
        actions = AwesomeForm.default_actions if actions.empty?

        actions.map {|f| action f, options }.join("\n").html_safe
      end

      def action(action, options={}, &block)
        action_options = options_for_action(action, options)

        render_options = {
          partial: partial_for_action(action_options),
          layout: wrapper_for_action(action_options),
          locals: { options: options }.merge(action_options),
        }
        render render_options
      end

    protected

      def options_for_action(action, options)
        options = {}
        options[:action] = action.to_sym

        case action.to_sym
        when :submit then options[:name] = :commit
        when :cancel then options[:name] = :cancel
        when :reset then options[:name] = :reset
        end

        options
      end

      def partial_for_action(action_options)
        paths = partial_paths_for_action(action_options)

        paths.select { |p| view_exists? p }.first
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

      def wrapper_for_action(action_options)
        "awesome_form/default_theme/wrappers/default"
      end
    end
  end
end
