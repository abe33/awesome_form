
class widgets.SingleSelect
  constructor: (@element, @options) ->

  init: ->
    @dummy = widgets.content_tag 'div', class: 'select-dummy', =>
      @select_value = widgets.content_tag 'div', @selected_label(), class: 'select-value'

    @element.parentNode.appendChild(@dummy)

    @create_drop_panel()
    @register_events @element
    this

  register_events: (element) ->
    element.addEventListener 'change', =>
      @select_value.innerHTML = @selected_label()

  create_drop_panel: ->
    panel = widgets.tag 'div', class: 'select-drop'
    options_container = widgets.tag 'div', class: 'select-options'

    options = @element.querySelectorAll 'option'

    Array::forEach.call options, (option, i) ->
      options_container.appendChild widgets.content_tag 'div', option.textContent, class: 'select-option', data: {
        index: i
        value: option.value
      }

    panel.appendChild options_container
    @dummy.appendChild panel

  selected_label: ->
    selected = @element.querySelector('option[selected]')

    if selected?
      selected.textContent
    else
      widgets.content_tag_html 'span', 'placeholder', class: 'placeholder'


widgets.define 'single_select', (element, options) ->
  new widgets.SingleSelect(element, options).init()

