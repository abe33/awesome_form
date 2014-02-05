
## widgets

# The `widgets` function is both the main module and the function
# used to register the widgets to apply on a page.
widgets = (name, selector, options={}, block) ->

  # The options specific to the widget registration and activation are
  # extracted from the options object.
  events = options.on
  if_condition = options.if
  unless_condition = options.unless
  media_condition = options.media

  delete options.on
  delete options.if
  delete options.unless
  delete options.media

  # Events can be passed as a string with event names separated with spaces.
  events = events.split /\s+/g if typeof events is 'string'

  # The widgets instances are stored in a Hash with the DOM element they
  # target as key. The instances hashes are stored per widget type.
  instances = widgets.instances[name] ||= new widgets.Hash

  # This method execute a test condition for the given element. The condition
  # can be either a function or a value converted to boolean.
  test_condition = (condition, element) ->
    if typeof condition is 'function' then condition(element) else !!condition

  # The DOM elements handled by a widget will receive a handled class
  # to differenciate them from unhandled elements.
  handled_class = "#{name}-handled"

  # This method will test if an element can be handled by the current widget.
  # It will test for both the handled class presence and the widget
  # conditions. Note that if both the `if` and `unless` conditions
  # are passed in the options object they will be tested as both part
  # of a single `&&` condition.
  can_be_handled = (element) ->
    res = element.className.indexOf(handled_class) is -1
    res &&= test_condition(if_condition, element) if if_condition?
    res &&= not test_condition(unless_condition, element) if unless_condition?
    res

  # If a media condition have been specified, the widget activation will be
  # conditionned based on the result of this condition. The condition is
  # verified each time the `resize` event is triggered.
  if media_condition?
    # The media condition can be either a boolean value, a function, or,
    # to simply the setup, an object with `min` and `max` property containing
    # the minimal and maximal window width where the widget is activated.
    if typeof media_condition is 'object'
      {min, max} = media_condition
      media_condition = ->
        res = true
        res &&= window.innerWidth >= min if min?
        res &&= window.innerWidth <= max if max?
        res

    # The media handl is registered on the `resize` event of the `window`
    # object.
    media_handler = (element, widget) ->
      return unless widget?

      condition_matched = test_condition(media_condition, element)

      if condition_matched and not widget.active
        widget.activate?()
      else if not condition_matched and widget.active
        widget.deactivate?()

    window.addEventListener 'resize', ->
      instances.each_pair (element, widget) ->
        media_handler element, widget

  # The `handler` function is the function registered on specified event and
  # will proceed to the creation of the widgets if the conditions are met.
  handler = ->
    elements = document.querySelectorAll selector

    Array::forEach.call elements, (element) ->
      return unless can_be_handled element

      res = widgets[name] element, Object.create(options)
      element.className += " #{handled_class}"
      instances.set element, res
      block?.call element, element, res

      # The widgets activation state are resolved at creation
      media_handler(element, res) if media_condition?

  # For each event specified, the handler is registered as listener.
  # A special case is the `init` event that simply mean to trigger the
  # handler as soon a the function is called.
  events.forEach (event) ->
    switch event
      when 'init' then handler()
      when 'load', 'resize'
        window.addEventListener event, handler
      else
        document.addEventListener event, handler

# The `instances` of the various widgets, stored by widget type and then
# mapped with their target DOM element as key.
widgets.instances = {}

#### widgets.define

# The `widgets.define` is used to create a new widget usable through the
# `widgets` method. Basically, a widget is defined using a `name`, and a
# `block` function that will be called for each DOM elements targeted by
# the widget.
#
# The `block` function should have the following signature:
#
#     function(element:HTMLElement, options:Object):Object
#
# The `options` object will contains all the options passed to the `widgets`
# method except the `on`, `if`, `unless` and `media` ones.
widgets.define = (name, block) -> widgets[name] = block

#### widgets.release

# The `widgets.release` method can be used to completely remove the widgets
# of the given `name` from the page.
# It's the widget responsibility to clean up its dependencies during
# the `dispose` call.
widgets.release = (name) ->
  widgets.instances[name].each (value) -> value?.dispose?()

#### widgets.activate

# Activates all the widgets instances of type `name`.
widgets.activate = (name) ->
  widgets.instances[name].each (value) -> value?.activate?()

#### widgets.deactivate

# Deactivates all the widgets instances of type `name`.
widgets.deactivate = (name) ->
  widgets.instances[name].each (value) -> value?.deactivate?()

window.widgets = widgets
