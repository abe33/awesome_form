module AwesomeForm
  module Methods
    module Labels

      def input_label(attribute_name)
        I18n.t("awesome_form.labels.#{resource_name}.#{attribute_name}", default: attribute_name.to_s.humanize)
      end

      def input_placeholder(attribute_name)
        I18n.t("awesome_form.placeholders.#{resource_name}.#{attribute_name}", default: '')
      end

      def input_hint(attribute_name)
        I18n.t("awesome_form.hints.#{resource_name}.#{attribute_name}", default: '')
      end

      def action_label(action)
        I18n.t("awesome_form.actions.#{resource_name}.#{action}", {
          default: I18n.t("awesome_form.actions.#{action}", {
            default: action.to_s.humanize
          })
        })
      end
    end
  end
end
