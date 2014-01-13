require 'spec_helper'

feature 'awesome_form_for used in a view', js: true do

  scenario 'for a new session' do
    visit '/sessions/new'

    match_content_of(page, '
      body
        form
          div
            input[name="utf8"][type="hidden"]

          input[name="user[email]"][type="email"]
          input[name="user[password]"][type="password"]
          input[name="user[remember_me]"][type="checkbox"]

          button[type="submit"][name="commit"]
    ')
  end
end
