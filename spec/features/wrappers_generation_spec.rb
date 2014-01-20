require 'spec_helper'

feature 'wrappers' do
  scenario 'for fields' do
    visit '/sessions/new'

    match_content_of(page,'
      form
        .field
          label[for="user_email_input"]
          .controls
            input[name="user[email]"][id="user_email_input"]

        .field
          input[name="user[remember_me]"][id="user_remember_me_input"]
          label[for="user_remember_me_input"]
    ')

    expect(page.find('label[for="user_email_input"]')).to have_content 'Email'
    expect(page.find('label[for="user_remember_me_input"]')).to have_content 'Remember me'
  end

  scenario 'for inputs and actions' do
    visit '/wrappers'

    match_content_of(page, '
      fieldset.inputs.foo
        input

      fieldset.actions.bar
        button
    ')

    expect(page.find('legend')).to have_content 'Irrelevant'
  end
end
