require 'spec_helper'

feature 'for more complex forms' do
  scenario 'such with fields_for' do
    visit '/fields_for'

    match_content_of(page, '
      form
        input[name="user[name]"]
        input[name="user[universe_attributes][name]"][type="text"]
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
    visit '/inputs'

    match_content_of(page, '
      form
        textarea[name="user[foo]"]
        input[name="user[foo]"][type="text"][value="bar"]
        input[name="user[foo]"][type="range"][value="5"][min][max][step]
        input[name="user[foo]"][type="number"][value="5"][min][max][step]
        input[name="user[foo]"][type="datetime"][value][min][max]
        input[name="user[foo]"][type="checkbox"][value="1"][checked]
        input[name="user[foo]"][type="file"]

    ')
  end

  scenario 'with data attributes' do
    visit '/data'

    match_content_of(page, '
      form
        input[data-id][data-type]
    ')
  end
end
