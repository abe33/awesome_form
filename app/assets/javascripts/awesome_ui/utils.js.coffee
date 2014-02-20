widgets.escape_html = (str) ->
  str
  .replace(/</g, '&lt;')
  .replace(/>/g, '&gt;')

widgets.strip_html = (str) ->
  n = document.createElement 'span'
  n.innerHTML = str
  n.textContent

widgets.self_and_ancestors = (node, block) ->
  block.call this, node
  widgets.ancestors node, block

widgets.ancestors = (node, block) ->
  parent = node.parentNode

  if parent? and parent isnt node
    block.call this, parent
    $w.ancestors parent, block

widget.find_ancestor = (element, query) ->
  for ancestor in widgets.all_ancestors(element)
    return ancestor if ancestor.matchesSelector? query

widgets.all_ancestors = (element) ->
  results = []
  widgets.ancestors element, (ancestor) -> results.push ancestor
  results

widgets.wrap_node = (node) ->
  return [] unless node?
  if node.length? then node else [node]

widgets.has_class = (nl, cls) ->
  nl = widgets.wrap_node nl

  Array::every.call nl, (n) -> ///(\s|^)#{cls}(\s|$)///.test n.className

widgets.add_class = (nl, cls) ->
  nl = widgets.wrap_node nl
  Array::forEach.call nl, (node) ->
    node.className += " #{cls}" unless widgets.has_class node, cls

widgets.remove_class = (nl, cls) ->
  nl = widgets.wrap_node nl
  Array::forEach.call nl, (node) ->
    node.className = node.className.replace cls, ''

widgets.toggle_class = (nl, cls, b) ->
  nl = widgets.wrap_node nl
  Array::forEach.call nl, (node) ->
    has_class = if b? then not b else widgets.has_class node, cls
    if has_class
      widgets.remove_class node, cls
    else
      widgets.add_class node, cls

widgets.dom_event = (type) ->
  new Event type, {
    bubbles: true
    cancelable: true
  }

