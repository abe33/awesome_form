require 'spec_helper'

feature 'fields wrappers' do
  scenario '' do
    visit '/sessions/new'

    match_content_of(page,'
      form
        .field
          label[for="user_email"]
          .controls
            input[name="user[email]"][id="user_email"]

        .field
          input[name="user[remember_me]"][id="user_remember_me"]
          label[for="user_remember_me"]
    ')

    expect(page.find('label[for="user_email"]')).to have_content 'Email'
    expect(page.find('label[for="user_remember_me"]')).to have_content 'Remember me'
  end

end
