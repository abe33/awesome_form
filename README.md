## AwesomeForm

[![Gem Version](https://badge.fury.io/rb/awesome_form.png)](http://badge.fury.io/rb/awesome_form)
[![Build Status](https://travis-ci.org/abe33/awesome_form.png)](https://travis-ci.org/abe33/awesome_form)
[![Coverage Status](https://coveralls.io/repos/abe33/awesome_form/badge.png)](https://coveralls.io/r/abe33/awesome_form)
[![Code Climate](https://codeclimate.com/github/abe33/awesome_form.png)](https://codeclimate.com/github/abe33/awesome_form)
[![Dependency Status](https://gemnasium.com/abe33/awesome_form.png)](https://gemnasium.com/abe33/awesome_form)

`AwesomeForm` is yet another form helper for `Rails`, but, contrary to `Formtastic` and `SimpleForm` it relies on partial views instead of html helpers.

Each input type is a partial in its theme directory, and wrappers are made using the `layout` option of the `render` method.

For instance, a boolean field will be rendered using a partial named `_boolean` in the `app/views/awesome_form` directory (See below for further explanation on partials lookup).

The same principles apply with form actions, each action is mapped to a partial file and eventually wrapped using a layout file.

### Usage

Using `AwesomeForm` doesn't differ much of using `Formtastic` or `SimpleForm`:

```haml
= awesome_form_for resource, url: resource_path(resource) do |form|

  = form.inputs :attribute, :another_attribute

  = form.input :some_attribute, as: :boolean

  = form.actions :submit, :cancel
```

### Model Attributes Discovery

When using the `inputs` method without any symbols as arguments (an options hash can be passed), the form builder will attempt to discover attributes of the model. By default it'll generate an input for every column of the model as well as for each association (both `belongs_to` and `has_many` associations).

Columns can be excluded by adding them to the `AwesomeForm.excluded_columns` array. By default, only timestamps columns are ignored.

```ruby
AwesomeForm.setup do |config|
  config.excluded_columns << %w(column_to_ignore another_column_to_ignore)
end
```

By default, both `belongs_to` and `has_many` associations appears in discovered model's attributes. The default associations are configurable using
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

Fields wrappers are just layouts, and as every layout, the content of the view is injected where the `yield` keyword is found in the layout.

#### Action Views Lookup

A similar lookup is performed to find actions's views and wrappers:

For the action itself:

  1. `awesome_form/actions/:object_name/:action`
  2. `awesome_form/:theme/actions/:object_name/:action`
  3. `awesome_form/actions/:action`
  4. `awesome_form/:theme/actions/:action`
  5. `awesome_form/default_theme/actions/:action`
  6. `awesome_form/actions/default`
  7. `awesome_form/:theme/actions/default`
  8. `awesome_form/default_theme/actions/default`

And for the wrapper:

  1. `awesome_form/wrappers/:object_name/:action`
  2. `awesome_form/:theme/wrappers/:object_name/:action`
  3. `awesome_form/wrappers/:action`
  4. `awesome_form/:theme/wrappers/:action`
  5. `awesome_form/default_theme/wrappers/:action`

As you may notice, the action wrapper lookup doesn't fallback on any default.

### Views Locals

When rendering a view for an input, both the layout and the input partial receive many locals that contains data about the field.

A basic input will receive:

  * `attribute_name`: The name of the attribute as passed to the `input` method.
  * `model_name`: The name of the model in `snake_case` format.
  * `resource_name`: The pluraized name of the model in `snake_case` format.
  * `object_name`: The name of the field prior to the call to `input`. For instance, when in a `fields_for` block for `user.created_at`, the `object_name` is equal `user[created_at]`.
  * `object`: A reference to the target object of the form.
  * `builder`: A reference to the builder object of the form.
  * `type`: The type of input to generate for the attribute.

And according to the model attribute type, the locals object will also contains more specialized properties:

  * `column_type`: For a simple column (not an association), it will contains the type of the database column such as defined in the schema (`:integer`, `:string`, etc.).
  * `association_type`: If the attribute is an association, the `association_type` is set with the name of the association (`:belongs_to`, `:has_many`, etc.).
  * `collection`: When `type` is `select` or `association`, an array containing the possible values for the field.
  * `selected`: When `type` is `select` or `association`, an array containing the selected values for the field.

And of course all the options passed to the `input` method are available as locals in the view.

Actions locals only differs in that `type` and `attribute_name` are replaced with `action` and `name`.
