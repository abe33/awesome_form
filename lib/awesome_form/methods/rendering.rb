module AwesomeForm
  module Methods
    module Rendering
      def render_method(name)
        plural = name.to_s.pluralize

        define_method plural do |*args, &block|
          keys, options = filter_arguments(*args)
          keys = send("default_keys_for_#{plural}") if keys.empty?

          keys.map {|f| send name, f, options }.join("\n").html_safe
        end

        define_method name do |key, options={}, &block|
          opts = send("options_for_#{name}", key, options)

          render_options = {
            partial: send("partial_for_#{name}", opts),
            layout: send("wrapper_for_#{name}", opts),
            locals: opts,
          }
          render render_options
        end
      end
    end
  end
end
