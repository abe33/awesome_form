require 'spec_helper'

feature 'semantic classes' do
  scenario 'on a form' do
    visit '/users/new'

    match_content_of(page, '
      form
        div.field.user.email
        div.field.user.dead.boolean

        button.action.user.submit
    ')
  end
end
