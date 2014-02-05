
widgets.tag = (name, attrs={}) ->
  flatten_object = (object, key) ->
    new_object = {}

    recursion = (object, new_object, prefix='') ->
      for k,v of object
        if typeof v is 'object'
          recursion v, new_object, prefix + k + '-'
        else
          new_object[prefix + k] = v

    recursion object, new_object
    new_object


  node = document.createElement name
  attrs = flatten_object attrs

  if attrs.id?
    node.id = attrs.id
    delete attrs.id

  if attrs.class?
    node.className = attrs.class
    delete attrs.class

  node.setAttribute(attr, value) for attr, value of attrs

  node

widgets.content_tag = (name, content='', attrs={}) ->
  [attrs, content] = [content, attrs] if typeof attrs is 'function'
  [attrs, content] = [content, ''] if typeof content is 'object'

  node = widgets.tag name, attrs
  node.innerHTML = if typeof content is 'function'
    res = content.call node
    res?.outerHTML or String(res)
  else
    String(content)
  node

widgets.tag_html = (name, attrs) -> widgets.tag(name, attrs).outerHTML
widgets.content_tag_html = (name, content, attrs) -> widgets.content_tag(name,content, attrs).outerHTML

