
class RadioGroup
  LEFT_ENTER_EASING = widgets.key_spline(0.385, 0.005, 0.6, 1.275)
  LEFT_EXIT_EASING = widgets.key_spline(0.55, -1, 0.75, 1.0)
  RIGHT_ENTER_EASING = widgets.key_spline(0.385, 0.005, 0.6, 1.275)
  RIGHT_EXIT_EASING = widgets.key_spline(0.55, -1, 0.65, 1.0)

  BOTTOM_SLIDE_EASING = widgets.key_spline(0.890, -0.060, 0.660, 1.610)
  TOP_SLIDE_EASING = widgets.key_spline(0.660, -0.2, 0.590, 1.045)

  EXIT_DURATION = 200
  ENTER_DURATION = 300
  SLIDE_DURATION = 300

  constructor: (@element, @options) ->

  init: ->
    @markers = []

    @rows = @element.querySelectorAll '.row'
    first_row = @rows[0]
    columns = first_row.querySelectorAll('.column')

    @register_coordinates(@rows)
    @track_height = first_row.parentNode.clientHeight

    rows_count = @rows.length
    columns_count = columns.length

    for i in [0..columns_count-1]
      track = document.createElement 'div'
      track.className = 'radios-track'
      track.style.height = "#{@track_height}px"

      marker = document.createElement 'div'
      marker.className = 'radios-marker'
      track.appendChild marker

      @markers.push marker

      columns[i].appendChild track

    @init_marker()

    this

  dispose: ->

  register_coordinates: (rows) ->
    @inputs_coordinates = inputs_coordinates = new widgets.Hash

    Array::forEach.call rows, (row, y) =>
      columns = row.children
      Array::forEach.call columns, (column, x) =>
        input = column.querySelector('input')
        inputs_coordinates.set input, {x, y}

        @register_events input

  register_events: (input) ->
    input.addEventListener 'change', =>
      @with_selected (selected, coordinates, marker, old_marker) ->
        if @current_coordinates?
          if coordinates.x > @current_coordinates.x
            @exit_right(old_marker)
            @enter_left(marker)
            @place_marker(marker, coordinates.y)

          else if coordinates.x < @current_coordinates.x
            @exit_left(old_marker)
            @enter_right(marker)
            @place_marker(marker, coordinates.y)
            @show_marker(marker)

          else if coordinates.y > @current_coordinates.y
            @slide_bottom(marker, @current_coordinates.y, coordinates.y)
          else if coordinates.y < @current_coordinates.y
            @slide_top(marker, @current_coordinates.y, coordinates.y)
        else
          @place_marker(marker, coordinates.y)

        @show_marker(marker)
        @current_coordinates = coordinates


  init_marker: ->
    @with_selected (selected, coordinates, marker, old_marker) ->
      @show_marker marker
      @current_coordinates = coordinates

      @place_marker marker, coordinates.y

  show_marker: (marker) ->
    marker.className += ' visible' if marker.className.indexOf 'visible' is -1

  with_selected: (block) ->
    selected = @element.querySelector 'input:checked'

    if selected?
      coordinates = @inputs_coordinates.get(selected)
      marker = @markers[coordinates.x]
      old_marker = @markers[@current_coordinates.x] if @current_coordinates?
      block?.call this, selected, coordinates, marker, old_marker


  place_marker: (marker, y) ->
    row = @rows[y]
    top = @element_top row
    bottom = @element_bottom row
    marker.style.top = "#{top}px"
    marker.style.bottom = "#{bottom}px"

  exit_right: (marker) ->
    widgets.animate marker, {
      left: {from: 2, to: 36},
      during: EXIT_DURATION,
      easing: LEFT_EXIT_EASING
    }
    widgets.animate marker, {
      right: {from: 2, to: -36},
      during: EXIT_DURATION,
      easing: RIGHT_EXIT_EASING
    }

  exit_left: (marker) ->
    widgets.animate marker, {
      left: {from: 2, to: -36},
      during: EXIT_DURATION,
      easing: RIGHT_EXIT_EASING
    }
    widgets.animate marker, {
      right: {from: 2, to: 36},
      during: EXIT_DURATION,
      easing: LEFT_EXIT_EASING
    }

  enter_left: (marker) ->
    widgets.animate marker, {
      left: {from: -36, to: 2},
      during: ENTER_DURATION,
      easing: LEFT_ENTER_EASING
    }
    widgets.animate marker, {
      right: {from: 36, to: 2},
      during: ENTER_DURATION,
      easing: RIGHT_ENTER_EASING
    }

  enter_right: (marker) ->
    widgets.animate marker, {
      left: {from: 36, to: 2},
      during: ENTER_DURATION,
      easing: RIGHT_ENTER_EASING
    }
    widgets.animate marker, {
      right: {from: -36, to: 2},
      during: ENTER_DURATION,
      easing: LEFT_ENTER_EASING
    }

  slide_bottom: (marker, from, to) ->
    y_start_top = @element_top @rows[from]
    y_start_bottom = @element_bottom @rows[from]

    y_end_top = @element_top @rows[to]
    y_end_bottom = @element_bottom @rows[to]

    widgets.animate marker, {
      top: {from: y_start_top, to: y_end_top},
      during: SLIDE_DURATION,
      easing: TOP_SLIDE_EASING
    }
    widgets.animate marker, {
      bottom: {from: y_start_bottom, to: y_end_bottom},
      during: SLIDE_DURATION,
      easing: BOTTOM_SLIDE_EASING
    }

  slide_top: (marker, from, to) ->
    y_start_top = @element_top @rows[from]
    y_start_bottom = @element_bottom @rows[from]

    y_end_top = @element_top @rows[to]
    y_end_bottom = @element_bottom @rows[to]

    widgets.animate marker, {
      top: {from: y_start_top, to: y_end_top},
      during: SLIDE_DURATION,
      easing: BOTTOM_SLIDE_EASING
    }
    widgets.animate marker, {
      bottom: {from: y_start_bottom, to: y_end_bottom},
      during: SLIDE_DURATION,
      easing: TOP_SLIDE_EASING
    }

  element_top: (element) ->
    element.offsetTop - element.parentNode.offsetTop

  element_bottom: (element) ->
    @track_height - (@element_top(element) + element.offsetHeight) + 2



widgets.define 'radios', (element, options) ->
  new RadioGroup(element, options).init()

