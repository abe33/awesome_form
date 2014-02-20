
class widgets.FilePicker
  @include mixins.Activable
  @include mixins.Disposable

  constructor: (@element, @options) ->
    @input = @element.querySelector 'input'
    @controls = @element.querySelector '.controls'
    @value = $w.content_tag 'div', 'placeholder', class: 'file-value placeholder'

    @controls.appendChild @value
    @activate()

  register_events: ->
    @input.addEventListener 'change', @on_change

  unregister_events: ->
    @input.removeEventListener 'change', @on_change

  on_change: =>
    value = @input.value
    $w.toggle_class @value, 'placeholder', value is ''
    @value.textContent = value or 'placeholder'

  on_activate: ->
    @register_events()

  on_deactivate: ->
    @unregister_events()

  on_dispose: ->
    @unregister_events()

widgets.define 'file', (element, options) ->
  new widgets.FilePicker element, options

