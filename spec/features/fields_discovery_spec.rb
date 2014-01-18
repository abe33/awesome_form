require 'spec_helper'

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
