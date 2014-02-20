class widgets.SlidePanel
  @include mixins.Activable
  @include mixins.Disposable

  constructor: (@element, @options) ->
    @parent = @element.parentNode
    {@placeholder} = @options
    @placeholder = 'Choose items'
    @next_sibling = @element.nextSibling
    @build_panel()
    @build_control()

  register_listeners: ->
    @control.addEventListener 'click', @open_panel
    @panel_title.addEventListener 'click', @close_panel
    @panel_content.addEventListener 'scroll', @on_scroll

  unregister_listeners: ->
    @control.removeEventListener 'click', @open_panel
    @panel_title.removeEventListener 'click', @close_panel
    @panel_content.removeEventListener 'scroll', @on_scroll

  build_control: ->
    @control = $w.content_tag 'div', class: 'slide-control', =>
      $w.content_tag_html('span', @placeholder, class: 'value') +
      $w.icon_html('chevron-right')

  build_panel: ->
    @panel = $w.tag 'div', class: 'slide-panel'
    @panel_title = $w.tag 'div', class: 'title'
    @panel_content = $w.tag 'div', class: 'content'

    @close_button = $w.content_tag 'div', $w.icon_html('times'), class: 'close'

    @panel_title.appendChild @close_button
    @panel.appendChild @panel_title
    @panel.appendChild @panel_content

  attach_panel: ->
    return if @panel.parentNode is @parent

    @parent.appendChild @panel
    e = $w.dom_event 'slide_panel:added'
    @panel.dispatchEvent e

  detach_panel: ->
    return unless @panel.parentNode is @parent

    @panel_title.removeAttribute('style')
    @parent.removeChild @panel
    e = $w.dom_event 'slide_panel:removed'
    @parent.dispatchEvent e

  attach_to_panel: ->
    @parent.appendChild @control
    @detach_from_parent()
    @panel_content.appendChild @element

  detach_from_panel: ->
    @parent.removeChild @control
    @panel_content.removeChild @element
    @attach_to_parent()

  attach_to_parent: ->
    if @next_sibling?
      @parent.insertBefore @element, @next_sibling
    else
      @parent.appendChild @element

  detach_from_parent: ->
    @parent.removeChild @element

  open_panel: =>
    @attach_panel()

    setTimeout =>
      $w.add_class @panel, 'open'
    , 100

    setTimeout =>
      e = $w.dom_event 'slide_panel:opened'
      @control.focus()
      @panel.dispatchEvent e
    , 600

  close_panel: =>
    $w.remove_class @panel, 'open'

    e = $w.dom_event 'slide_panel:closed'
    @panel.dispatchEvent e

    setTimeout =>
      @detach_panel()
    , 600

  on_scroll: =>
    $w.toggle_class @panel_title, 'detached', @panel_content.scrollTop > 0

  on_activate: ->
    @attach_to_panel()
    @register_listeners()

  on_deactivate: ->
    @unregister_listeners()
    @detach_from_panel()
    @detach_panel()
    $w.remove_class @panel, 'open'

  on_dispose: ->
    @detach_from_panel()
    @detach_panel()

widgets.define 'slide_panel', (element, options) ->
  new widgets.SlidePanel element, options
