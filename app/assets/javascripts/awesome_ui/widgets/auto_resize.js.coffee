class widgets.TextAreaAutoResize
  @include mixins.Activable
  @include mixins.Disposable

  constructor: (@element) ->
    @resize()
    @register_listeners()

  resize: ->
    @element.style.height = 'auto'
    @element.style.height = @element.scrollHeight + 'px'

  register_listeners: ->
    @element.addEventListener 'input', @input_listener

  unregister_listeners: ->
    @element.removeEventListener 'input', @input_listener

  input_listener: => setTimeout (=> @resize(); true), 0

  on_activate: ->
    @register_listeners()
    @resize()

  on_deactivate: ->
    @unregister_listeners()
    @element.style.height = null

  on_dispose: ->
    @unregister_listeners()

widgets.define 'auto_resize', (el) ->
  new widgets.TextAreaAutoResize el

