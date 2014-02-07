
class RadioGroup
  @include mixins.Activable

  @LEFT_ENTER_EASING: widgets.key_spline(0.385, 0.005, 0.6, 1.275)
  @LEFT_EXIT_EASING: widgets.key_spline(0.55, -1, 0.75, 1.0)

  @RIGHT_ENTER_EASING: widgets.key_spline(0.385, 0.005, 0.6, 1.275)
  @RIGHT_EXIT_EASING: widgets.key_spline(0.55, -1, 0.65, 1.0)

  @TOP_OFFSET: 11
  @TOP_SLIDE_EASING: widgets.key_spline(0.660, -0.2, 0.590, 1.045)

  @BOTTOM_OFFSET: 4
  @BOTTOM_SLIDE_EASING: widgets.key_spline(0.890, -0.060, 0.660, 1.610)

  @EXIT_DURATION = 200
  @ENTER_DURATION = 300
  @SLIDE_DURATION = 300

  constructor: (@element, @options) ->

  init: ->
    @markers = []
    @tracks = new widgets.Hash

    @update_rows()
    @update_height()

    for i in [0..@columns_count-1]
      track = widgets.tag 'div', class: 'radios-track', style: "height: #{@track_height}px"

      marker = widgets.tag 'div', class: 'radios-marker'
      track.appendChild marker

      @markers.push marker
      @tracks.set track, @columns[i]

      @columns[i].appendChild track

    @init_marker()

    this

  update_rows: ->
    @rows = @element.querySelectorAll '.row'
    @first_row = @rows[0]
    @columns = @first_row.querySelectorAll('.column')
    @rows_count = @rows.length
    @columns_count = @columns.length

    @register_coordinates(@rows)

  update_height: ->
    @track_height = @first_row.parentNode.clientHeight
    @tracks.each_key (track) =>
      track.setAttribute 'style', "height: #{@track_height}px"

  dispose: ->

  on_activate: ->
    @update_height()
    @tracks.each_pair (track, column) ->
      column.appendChild track

    @with_selected (selected, coordinates, marker, old_marker) ->
      @show_marker marker
      @enter_left(marker)
      @place_marker marker, coordinates.y

  on_deactivate: ->
    @tracks.each_pair (track, column) ->
      column.removeChild track

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
          @enter_left(marker)
          @place_marker(marker, coordinates.y)

        @show_marker(marker)
        @current_coordinates = coordinates


  init_marker: ->
    @with_selected (selected, coordinates, marker, old_marker) ->
      @show_marker marker
      @current_coordinates = coordinates

      @enter_left(marker)
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
    top = @marker_top row
    bottom = @marker_bottom row
    marker.style.top = "#{top}px"
    marker.style.bottom = "#{bottom}px"

  exit_right: (marker) ->
    widgets.animate marker, {
      left: {from: 2, to: 36},
      during: RadioGroup.EXIT_DURATION,
      easing: RadioGroup.LEFT_EXIT_EASING
    }
    widgets.animate marker, {
      right: {from: 2, to: -36},
      during: RadioGroup.EXIT_DURATION,
      easing: RadioGroup.RIGHT_EXIT_EASING
    }

  exit_left: (marker) ->
    widgets.animate marker, {
      left: {from: 2, to: -36},
      during: RadioGroup.EXIT_DURATION,
      easing: RadioGroup.RIGHT_EXIT_EASING
    }
    widgets.animate marker, {
      right: {from: 2, to: 36},
      during: RadioGroup.EXIT_DURATION,
      easing: RadioGroup.LEFT_EXIT_EASING
    }

  enter_left: (marker) ->
    widgets.animate marker, {
      left: {from: -36, to: 2},
      during: RadioGroup.ENTER_DURATION,
      easing: RadioGroup.LEFT_ENTER_EASING
    }
    widgets.animate marker, {
      right: {from: 36, to: 2},
      during: RadioGroup.ENTER_DURATION,
      easing: RadioGroup.RIGHT_ENTER_EASING
    }

  enter_right: (marker) ->
    widgets.animate marker, {
      left: {from: 36, to: 2},
      during: RadioGroup.ENTER_DURATION,
      easing: RadioGroup.RIGHT_ENTER_EASING
    }
    widgets.animate marker, {
      right: {from: -36, to: 2},
      during: RadioGroup.ENTER_DURATION,
      easing: RadioGroup.LEFT_ENTER_EASING
    }

  slide_bottom: (marker, from, to) ->
    y_start_top = @marker_top @rows[from]
    y_start_bottom = @marker_bottom @rows[from]

    y_end_top = @marker_top @rows[to]
    y_end_bottom = @marker_bottom @rows[to]

    widgets.animate marker, {
      top: {from: y_start_top, to: y_end_top},
      during: RadioGroup.SLIDE_DURATION,
      easing: RadioGroup.TOP_SLIDE_EASING
    }
    widgets.animate marker, {
      bottom: {from: y_start_bottom, to: y_end_bottom},
      during: RadioGroup.SLIDE_DURATION,
      easing: RadioGroup.BOTTOM_SLIDE_EASING
    }

  slide_top: (marker, from, to) ->
    y_start_top = @marker_top @rows[from]
    y_start_bottom = @marker_bottom @rows[from]

    y_end_top = @marker_top @rows[to]
    y_end_bottom = @marker_bottom @rows[to]

    widgets.animate marker, {
      top: {from: y_start_top, to: y_end_top},
      during: RadioGroup.SLIDE_DURATION,
      easing: RadioGroup.BOTTOM_SLIDE_EASING
    }
    widgets.animate marker, {
      bottom: {from: y_start_bottom, to: y_end_bottom},
      during: RadioGroup.SLIDE_DURATION,
      easing: RadioGroup.TOP_SLIDE_EASING
    }

  marker_top: (element) ->
    RadioGroup.TOP_OFFSET + element.offsetTop - element.parentNode.offsetTop

  marker_bottom: (element) ->
    @track_height - (@marker_top(element) + element.offsetHeight) + RadioGroup.BOTTOM_OFFSET

widgets.define 'radios', (element, options) ->
  new RadioGroup(element, options).init()

