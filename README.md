## AwesomeForm

[![Build Status](https://travis-ci.org/abe33/awesome_form.png)](https://travis-ci.org/abe33/awesome_form)
[![Coverage Status](https://coveralls.io/repos/abe33/awesome_form/badge.png)](https://coveralls.io/r/abe33/awesome_form)
[![Code Climate](https://codeclimate.com/github/abe33/awesome_form.png)](https://codeclimate.com/github/abe33/awesome_form)
[![Dependency Status](https://gemnasium.com/abe33/awesome_form.png)](https://gemnasium.com/abe33/awesome_form)

`AwesomeForm` is yet another form helper for `Rails`, but, contrary to `Formtastic` and `SimpleForm` it rely on partial views instead of html helpers.

Each input type is a partial in its theme directory, and wrappers are made using the `layout` option of the `render` method.

For instance, a boolean field will be rendered using a partial named `_boolean` in the `app/views/awesome_form` directory (See below for further explanation on partials lookup).

The same principles apply with form actions, each action is map to a partial file and eventually wrapped using a layout file.

### Usage

Using `AwesomeForm` doesn't differ much of using `Formtastic` or `SimpleForm`:

```haml
= awesome_form_for resource, url: resource_path(resource) do |form|

  = form.inputs :attribute, :another_attribute

  = form.input :some_attribute, as: :boolean

  = form.actions :submit, :cancel
```

### Model Attributes Discovery

When using the `inputs` method without any arguments, the form builder will attempt to discover attributes of the model. By default it'll generates an input for every columns of the model as well as for each association (both `belongs_to` and `has_many` associations).

Columns can be excluded by adding them to the `AwesomeForm.excluded_columns` array. By default, only timestamps columns are ignored.

```ruby
AwesomeForm.setup do |config|
  config.excluded_columns << %w(column_to_ignore another_column_to_ignore)
end
```

By default, both `belongs_to` and `has_many` associations appears in discovered model's attributes. The default association are editable using
the `AwesomeForm.default_associations` config.

```ruby
AwesomeForm.setup do |config|
  config.default_associations = [:belongs_to]
end
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

#### Inputs Wrappers

The same kind of lookup is used for fields wrappers, but instead of looking into the `inputs` view directory, it'll look into the `wrappers` directory.

  1. `app/views/awesome_form/wrappers/:object_name/:attribute_name`
  2. `app/views/awesome_form/:theme/wrappers/:object_name/:attribute_name`
  3. `app/views/awesome_form/wrappers/:attribute_type`
  4. `app/views/awesome_form/:theme/wrappers/:attribute_type`
  5. `app/views/awesome_form/default_theme/wrappers/:attribute_type`
  6. `app/views/awesome_form/wrappers/default`
  7. `app/views/awesome_form/:theme/wrappers/default`
  8. `app/views/awesome_form/default_theme/wrappers/default`
