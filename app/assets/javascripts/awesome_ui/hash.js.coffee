
class widgets.Hash
  constructor: ->
    @clear()

  clear: ->
    @keys = []
    @values = []

  set: (key, value) ->
    @keys.push(key)
    @values.push(value)

  get: (key) ->
    @values[@keys.indexOf key]

  get_key: (value) ->
    @keys[@values.indexOf value]

  unset: (key) ->
    index = @keys.indexOf key
    @keys.splice(index, 1)
    @values.splice(index, 1)

  each: (block) -> @values.forEach block
