module AwesomeForm
  module Methods
    module Rendering
      def render_method(name)
        plural = name.to_s.pluralize

        class_eval <<-RUBY, __FILE__, __LINE__+1

          def #{plural}(*args, &block)
            keys, options = filter_arguments(*args)
            keys = send("default_keys_for_#{plural}") if keys.empty?

            theme = AwesomeForm.theme

            paths = [
              "awesome_form/wrappers/_#{plural}",
              "awesome_form/" + theme.to_s + "/wrappers/_#{plural}",
              "awesome_form/default_theme/wrappers/_#{plural}",
            ]

            text = default_#{plural}_content(options)
            text << keys.map { |f| #{name} f, options }.join("\n").html_safe
            text << @template.capture(self, &block) if block_given?

            render text: text, layout: lookup_views(paths)
          end

          def #{name}(key, options={}, &block)
            opts = send("options_for_#{name}", key, options)

            render_options = {
              partial: send("partial_for_#{name}", opts),
              layout: send("wrapper_for_#{name}", opts),
              locals: opts,
            }
            render render_options
          end

        RUBY

      end
    end
  end
end
