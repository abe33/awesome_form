class mixins.Disposable
  dispose: ->
    @on_dispose?()
    delete @element
    delete @options
