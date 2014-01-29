
widgets = (name, selector, options={}, block) ->
  events = options.on
  events = events.split /\s+/g if typeof events is 'string'
  instances = widgets.instances[name] ||= new widgets.Hash

  handler = (e) ->
    elements = document.querySelectorAll "#{selector}:not(.#{name}-handled)"

    Array::forEach.call elements, (element) ->
      res = widgets[name] element, Object.create(options)
      element.className += " #{name}-handled"
      instances.set element, res
      block?.call element, element, res

  events.forEach (event) ->
    switch event
      when 'load'
        window.addEventListener event, handler
      else
        document.addEventListener event, handler

widgets.instances = {}

widgets.define = (name, block) -> widgets[name] = block

widgets.release = (name) ->
  widgets.instances[name].each (value) -> value?.dispose?()

window.widgets = widgets
