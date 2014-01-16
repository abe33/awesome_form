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
  let(:universe) { FactoryGirl.create :universe }

  before { universe }

  scenario 'for a new user' do

    visit '/users/new'

    match_content_of(page, '
      form#new_user
        input[name="user[name]"]
        input[name="user[email]"]
        input[name="user[dead]"][type="checkbox"]
        input[name="user[born_at]"][type="datetime"]
        select[name="user[universe_id]"]
          option[value="1"]
    ')
  end

  scenario 'for a new universe' do
    visit '/universes/new'

    match_content_of(page, '
      form#new_universe
        input[name="universe[name]"]
        input[name="universe[entropy]"][type="number"]
        input[name="universe[light_years]"][type="number"]
        select[name="universe[user_ids][]"][multiple]
    ')
  end
end

feature 'for more complex forms' do
  scenario 'such with fields_for' do
    visit '/fields_for'

    match_content_of(page, '
      form
        input[name="user[name]"]
        input[name="user[universe_attributes][name]"][type="string"]
    ')
  end

  scenario 'with custom select collection' do
    visit '/selects'

    match_content_of(page, '
      form
        select[name="universe[bar]"]
          option[value=""]
          option[value="1"]
          option[value="10"]
          option[value="100"][selected]
          option[value="1000"]

        select[name="universe[foo][]"][multiple]
          option[value=""]
          option[value="a"][selected]
          option[value="b"][selected]
          option[value="c"]
          option[value="d"]
          option[value="e"][selected]
          option[value="f"]
    ')
  end

  scenario 'with all inputs type' do
    visit '/all_inputs'

    match_content_of(page, '
      form
        textarea[name="user[foo]"]
        input[name="user[foo]"][type="string"][value="bar"]
        input[name="user[foo]"][type="range"][value="5"][min][max][step]
        input[name="user[foo]"][type="number"][value="5"][min][max][step]
        input[name="user[foo]"][type="datetime"][value][min][max]
        input[name="user[foo]"][type="checkbox"][value="1"][checked]
        input[name="user[foo]"][type="file"]

    ')
  end
end
