#= require_tree ./awesome_ui/shame
#= require_tree ./awesome_ui/vendor
#= require awesome_ui/mixins
#= require_tree ./awesome_ui/mixins
#= require awesome_ui/widgets
#= require awesome_ui/tags
#= require awesome_ui/hash
#= require awesome_ui/utils
#= require awesome_ui/animations
#= require_tree ./awesome_ui/inputs
#= require_tree ./awesome_ui/widgets

css_selector = (selectors) -> selectors.join ', '

WIDGETS_EVENTS = 'load'
INPUTS_WITH_KEYBOARD = css_selector([
  'input[type=text]'
  'input[type=email]'
  'input[type=number]'
  'input[type=datetime]'
  'input[type=date]'
  'textarea'
])

CHECKED_INPUTS = css_selector([
  'input[type=radio]'
  'input[type=checkbox]'
])

CUSTOM_SELECTS = css_selector([
  '.check_boxes .controls'
  '.radios:not(.binary) .controls'
])

widget 'fast_click', 'body', on: WIDGETS_EVENTS
widget 'single_select', 'select:not([multiple])', on: WIDGETS_EVENTS
widget 'output', 'output', on: WIDGETS_EVENTS
widget 'auto_resize', 'textarea', on: WIDGETS_EVENTS
widget 'file', '.file', on: WIDGETS_EVENTS
widget 'sticky', '.sticky', on: WIDGETS_EVENTS + ' slide_panel:added'
widget 'checked_input', CHECKED_INPUTS, on: WIDGETS_EVENTS
widget 'radios', '.radios', on: WIDGETS_EVENTS, media: { min: 769 }
widget 'slide_panel', CUSTOM_SELECTS, on: WIDGETS_EVENTS, media: { max: 768 }, (el, widget) ->
  value = widget.control.querySelector '.value'
  field_label = widget.parent.querySelector 'label'
  inputs = widget.element.querySelectorAll 'input'
  widget.panel_title.appendChild $w.content_tag 'label', field_label.textContent
  update_selection = ->
    selected = Array::filter.call inputs, (input) -> input.checked

    if selected.length > 0
      $w.remove_class value, 'placeholder'
      value.textContent = selected.map (input) ->
        $w.find_ancestor(input, '.column').querySelector('label').textContent

    else
      $w.add_class value, 'placeholder'
      value.textContent = widget.placeholder

  update_selection()
  widget.parent.addEventListener 'slide_panel:closed', update_selection

