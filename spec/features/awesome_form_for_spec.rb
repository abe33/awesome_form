require 'spec_helper'

feature 'awesome_form_for used in a view', js: true do

  scenario 'for a new session' do
    visit '/sessions/new'

    match_content_of(page, '
      body
        form
          div
            input[name="utf8"][type="hidden"]

          input[name="email"][type="email"]
          input[name="password"][type="password"]
          input[name="remember_me"][type="checkbox"]
    ')
  end
end
