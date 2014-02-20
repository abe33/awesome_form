
class widgets.CheckedInput
  @include mixins.Disposable

  constructor: (@element, @options) ->
    @register_listeners()
    @on_change()

  register_listeners: ->
    @element.addEventListener 'change', @on_change

  unregister_listeners: ->
    @element.removeEventListener 'change', @on_change

  on_dispose: ->
    @unregister_listeners()

  on_change: =>
    $w.toggle_class(@element, 'checked', @element.checked)

widgets.define 'checked_input', (element, options) ->
  new widgets.CheckedInput element, options
