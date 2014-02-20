class widgets.Sticker
  @include mixins.Activable
  @include mixins.Disposable

  constructor: (@element, @options) ->

    {header_offset, @offset} = options
    @offset = 0 unless @offset?
    header_offset = 0 unless header_offset?

    @previous = @element.previousSibling
    @header_offset = header_offset + @offset
    @min_offset = parseInt(@element.getAttribute('data-sticky-offset') or 0, 10)

    container_selector = @element.getAttribute('data-sticky-container-selector')
    scroll_selector = @element.getAttribute('data-sticky-scroll-selector')

    if container_selector?
      @parent = $w.find_ancestor @element, container_selector

    @parent = document.querySelector 'html' unless @parent?

    if scroll_selector?
      @scroll_container = $w.find_ancestor @element, scroll_selector

    @scroll_container = window unless @scroll_container?

    @register_listeners()

  register_listeners: ->
    @scroll_container.addEventListener 'scroll', @on_scroll

  unregister_listeners: ->
    @scroll_container.removeEventListener 'scroll', @on_scroll

  on_activate: ->
    @on_scroll()

  on_deactivate: ->
    @element.style.top = null

  on_dispose: ->
    @unregister_listeners()
    delete @previous
    delete @header_offset
    delete @min_offset
    delete @offset

  on_scroll: =>
    return unless @active

    parent_offset = @parent.offsetTop
    if @previous?
      start = @previous.offsetTop + @previous.clientHeight - parent_offset - @header_offset
    else
      start = 0
    end = @parent.clientHeight - @element.clientHeight - @header_offset

    max_scroll = end - start

    if max_scroll > @offset
      y = @scroll_container.scrollTop or @scroll_container.scrollY or 0
      offset = y - parent_offset - start
      @apply_scroll max_scroll, offset

  apply_scroll: (max_scroll, offset) ->
    offset = Math.max(@min_offset, Math.min(max_scroll, offset))
    if offset is 0
      $w.remove_class @element, 'detached'
      @element.style.top = null
    else
      $w.add_class @element, 'detached'
      @element.style.top = "#{offset}px"

widgets.define 'sticky', (element, options) ->
  new widgets.Sticker element, options
