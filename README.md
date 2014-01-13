## AwesomeForm

[![Build Status](https://travis-ci.org/abe33/awesome_form.png)](https://travis-ci.org/abe33/awesome_form)
[![Coverage Status](https://coveralls.io/repos/abe33/awesome_form/badge.png)](https://coveralls.io/r/abe33/awesome_form)
[![Code Climate](https://codeclimate.com/github/abe33/awesome_form.png)](https://codeclimate.com/github/abe33/awesome_form)
[![Dependency Status](https://gemnasium.com/abe33/awesome_form.png)](https://gemnasium.com/abe33/awesome_form)

`AwesomeForm` is yet another form helper for `Rails`, but, contrary to `Formtastic` and `SimpleForm` it rely on partial views and not on html helpers.

### Usage


```haml
= awesome_form_for resource, url: resource_path(resource) do |form|

  = form.inputs :attribute, :another_attribute

  = form.input :some_attribute, as: :boolean

  = form.actions :submit, :cancel

```


### Views Lookup

The lookup process for a form input takes place as follow:

First, we look for a partial for the given model attribute, either
at the top level or in the selected theme:

  1. `app/views/awesome_form/inputs/:object_name/:attribute_name`
  2. `app/views/awesome_form/:theme/inputs/:object_name/:attribute_name`

If a partial cannot be found for the model attribute, we look for a
partial for the attribute's type:

  3. `app/views/awesome_form/inputs/:attribute_type`
  4. `app/views/awesome_form/:theme/inputs/:attribute_type`
  5. `app/views/awesome_form/default_theme/inputs/:attribute_type`

And if there's no partial for the attribute's type, we look for the
default input partial.

  6. `app/views/awesome_form/inputs/default`
  7. `app/views/awesome_form/:theme/inputs/default`
  8. `app/views/awesome_form/default_theme/inputs/default`

