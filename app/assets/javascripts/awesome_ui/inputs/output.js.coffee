widgets.define 'output', (element, options={}) ->
  target = document.getElementById element.getAttribute 'for'

  target.addEventListener 'change', ->
    element.textContent = target.value

  target.addEventListener 'input', ->
    element.textContent = target.value

  element.textContent = target.value
