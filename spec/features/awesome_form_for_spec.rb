require 'spec_helper'

feature 'awesome_form_for used in a view', js: true do

  scenario 'for a new session' do
    visit '/sessions/new'

    p AwesomeForm::DOM::DomExpression.new('
          html
            head
              title
            body
              form
                "form"
        '
    ).match(page)
    expect(page.all('form').length).to eq 1
  end
end
