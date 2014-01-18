module AwesomeForm
  module Methods
    module Labels

      def input_label(attribute_name)
        I18n.t("awesome_form.labels.#{model_name}.#{attribute_name}", default: attribute_name.to_s.humanize)
      end

      def action_label(action)
        I18n.t("awesome_form.actions.#{model_name}.#{action}", {
          default: I18n.t("awesome_form.actions.#{action}", {
            default: action.to_s.humanize
          })
        })
      end
    end
  end
end
