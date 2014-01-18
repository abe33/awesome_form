require 'spec_helper'

feature 'generating actions' do

  scenario 'with various type' do
    visit '/actions'

    match_content_of(page, '
      button[type="submit"]
      button[type="reset"]
    ')
  end
end
