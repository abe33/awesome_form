class mixins.Activable
  active: false

  activate: ->
    @active = true
    @on_activate?()

  deactivate: ->
    @active = false
    @on_deactivate?()

