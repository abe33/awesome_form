#= require awesome_ui/mixins
#= require_tree ./awesome_ui/mixins
#= require awesome_ui/widgets
#= require awesome_ui/tags
#= require awesome_ui/hash
#= require awesome_ui/animations
#= require_tree ./awesome_ui/inputs

WIDGETS_EVENTS = 'load'

widgets 'radios', '.radios', on: WIDGETS_EVENTS, media: { min: 768 }
widgets 'single_select', 'select:not([multiple])', on: WIDGETS_EVENTS
widgets 'output', 'output', on: WIDGETS_EVENTS
