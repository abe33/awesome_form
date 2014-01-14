require 'spec_helper'

feature 'awesome_form_for used in a view', js: true do

  scenario 'for a new session' do
    visit '/sessions/new'

    match_content_of(page, '
      body
        form
          div
            input[name="utf8"][type="hidden"]

          .field
            input[name="user[email]"][type="email"]
          .field
            input[name="user[password]"][type="password"]
          .field
            input[name="user[remember_me]"][type="checkbox"]

          .field
            button[type="submit"][name="commit"]
    ')
  end
end
