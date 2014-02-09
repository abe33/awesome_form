require 'spec_helper'

feature 'input placeholder' do
  scenario '' do
    visit '/placeholders'

    match_content_of(page, '
      input[placeholder]
    ')
  end
end
