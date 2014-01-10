require 'spec_helper'

feature 'awesome_form_for used in a view', js: true do

  scenario 'for a new session' do
    visit '/sessions/new'

    AwesomeForm::DOM::DomExpression.new('
      html
        body
          form
    ', self).match(page)
  end
end
