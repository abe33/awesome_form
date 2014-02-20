require 'spec_helper'

feature 'required fields' do

  scenario 'with both set as option or discovered' do
    visit '/required'

    match_content_of(page, '
      input[name="universe[light_years]"][required]
      input[name="universe[created_at]"][required]
    ')
  end
end
