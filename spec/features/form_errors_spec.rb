require 'spec_helper'

feature 'errors' do
  scenario 'in a form that have errors' do
    visit '/with_errors'

    match_content_of(page, '
      form
        .field.has-errors
          label
          .controls
          .inline-error
    ')
  end
end
