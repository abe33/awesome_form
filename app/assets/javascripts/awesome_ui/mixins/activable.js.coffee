class mixins.Activable
  active: true

  activate: ->
    @active = true
    @on_activate?()

  deactivate: ->
    @active = false
    @on_deactivate?()

