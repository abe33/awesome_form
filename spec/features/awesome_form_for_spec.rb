require 'spec_helper'

feature 'awesome_form_for used in a view', js: true do

  scenario 'for a new session' do
    visit '/sessions/new'

    match_content_of(page, '
      body
        form#new_user
          div
            input[name="utf8"][type="hidden"]

          input[name="user[email]"][type="email"]
          input[name="user[password]"][type="password"]
          input[name="user[remember_me]"][type="checkbox"]

          button[type="submit"][name="commit"]
    ')

    match_content_of(page, '.field > input[name="user[email]"][type="email"]')
  end
end

feature 'discovering models field', js: true do
  scenario 'for a new user' do
    visit '/users/new'

    match_content_of(page, '
      form#new_user
        input[name="user[name]"]
        input[name="user[email]"]
        input[name="user[dead]"]
        input[name="user[born_at]"]
        select[name="user[universe_id]"]
    ')
  end

  scenario 'for a new universe' do
    visit '/universes/new'

    match_content_of(page, '
      form#new_universe
        input[name="universe[name]"]
        input[name="universe[entropy]"]
        input[name="universe[light_years]"]
        select[name="universe[user_ids][]"][multiple]
    ')
  end

end
