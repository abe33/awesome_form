require 'spec_helper'

feature 'block handling' do
  scenario '' do
    visit '/blocks'

    match_content_of(page, '
      fieldset.inputs
        input[name="user[name]"]
        input[name="user[email]"]
    ')
  end
end
