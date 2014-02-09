require 'spec_helper'

feature 'input hint' do
  scenario '' do
    visit '/hints'

    match_content_of(page, '
      .field
        .hint
    ')

    expect(page.find('.hint')).to have_content 'foo'
  end
end
