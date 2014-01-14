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

    match_content_of(page, '.field > input[name="user[email]"][type="email"]')
    match_content_of(page, '.field > button[type="submit"]')
  end
end

feature 'discovering models field', js: true do
  scenario 'for a new user' do
    visit '/users/new'

    match_content_of(page, '
      form
        input[name="user[name]"]
        input[name="user[email]"]
        input[name="user[dead]"]
        input[name="user[born_at]"]
        select[name="user[universe_id]"]
    ')
  end

end
