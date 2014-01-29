window.requestAnimationFrame =
  window.requestAnimationFrame or
  window.webkitRequestAnimationFrame or
  window.mozRequestAnimationFrame or
  (callback) -> window.setTimeout(callback, 1000 / 60)

widgets.key_spline = (m_x1, m_y1, m_x2, m_y2) ->
  # linear
  A = (a1, a2) ->
    1.0 - 3.0 * a2 + 3.0 * a1
  B = (a1, a2) ->
    3.0 * a2 - 6.0 * a1
  C = (a1) ->
    3.0 * a1

  # Returns x(t) given t, x1, and x2, or y(t) given t, y1, and y2.
  calc_bezier = (a_t, a1, a2) ->
    ((A(a1, a2) * a_t + B(a1, a2)) * a_t + C(a1)) * a_t

  # Returns dx/dt given t, x1, and x2, or dy/dt given t, y1, and y2.
  get_slope = (a_t, a1, a2) ->
    3.0 * A(a1, a2) * a_t * a_t + 2.0 * B(a1, a2) * a_t + C(a1)

  get_t_for_x = (a_x) ->
    # Newton raphson iteration
    guess_t = a_x
    i = 0

    while i < 4
      current_slope = get_slope(guess_t, m_x1, m_x2)
      return guess_t  if current_slope is 0.0
      currentX = calc_bezier(guess_t, m_x1, m_x2) - a_x
      guess_t -= currentX / current_slope
      ++i
    guess_t

  return (a_x) ->
    return a_x if m_x1 is m_y1 and m_x2 is m_y2
    calc_bezier get_t_for_x(a_x), m_y1, m_y2

widgets.Easing =
  linear: (t) -> t
  ease: widgets.key_spline(0.25, 0.1, 0.25, 1.0)
  linear: widgets.key_spline(0.00, 0.0, 1.00, 1.0)
  ease_in: widgets.key_spline(0.42, 0.0, 1.00, 1.0)
  ease_out: widgets.key_spline(0.00, 0.0, 0.58, 1.0)
  ease_in_out: widgets.key_spline(0.42, 0.0, 0.58, 1.0)

class widgets.PropertyTransition
  constructor: (@from=0, @to) ->

  get: (t) -> "#{@from + (@to - @from) * t}px"

class widgets.Animation
  constructor: (@element, @properties, @duration, @easing) ->
    @time = 0
    @finished = false

    @property_transitions = {}
    for k,v of @properties
      from = null
      to = null

      if typeof v is 'object'
        {from, to} = v
      else
        to = v

      unless from?
        from = @element.style[k]

      if from is ''
        from = null

      @property_transitions[k] = new widgets.PropertyTransition from, to

  animate: (t) ->
    @time += t
    easing_position = @easing @time / @duration

    if @time >= @duration
      @finished = true
      easing_position = 1

    for k,v of @properties
      @element.style[k] = @property_transitions[k].get(easing_position)

class widgets.AnimationManager
  constructor: ->
    @animations = []
    @last_time = new Date()
    @animate()

  animate: ->
    time = new Date()
    dif = time - @last_time

    @animations = @animations.filter (animation) =>
      animation.animate(dif)
      not animation.finished

    @last_time = time
    requestAnimationFrame => @animate()

  add: (animation) ->
    @animations.push animation
    animation.animate(0)

widgets.animate = (element, options) ->
  widgets.animation_manager ||= new widgets.AnimationManager

  easing = widgets.Easing.linear
  duration = 1000

  if options.easing?
    easing = options.easing
    delete options.easing

  if options.during?
    duration = options.during
    delete options.during

  animation = new widgets.Animation element, options, duration, easing

  widgets.animation_manager.add animation





