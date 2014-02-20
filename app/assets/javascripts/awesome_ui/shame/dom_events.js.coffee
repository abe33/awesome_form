methods = [
  ['appendChild', 'added']
  ['insertBefore', 'added']
  ['removeChild', 'removed']
]

methods.forEach ([method, event]) ->
  safe = Element::[method]
  Element::[method] = (child) ->
    res = safe.apply(this, arguments)
    e = new Event "child:#{event}", {
      target: this
      related: child
      bubbles: true
      cancelable: true
    }
    @dispatchEvent e

    e = new Event event, {
      target: child
      related: this
      bubbles: true
      cancelable: true
    }
    child.dispatchEvent e
    res
