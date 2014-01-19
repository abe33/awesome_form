require 'spec_helper'

feature 'semantic classes' do
  scenario 'on a form' do
    visit '/users/new'

    match_content_of(page, '
      form
        input.input.user.email

        button.action.user.submit
    ')
  end
end
