isCommonJS = typeof module isnt "undefined"

if isCommonJS
  exports = module.exports or {}
else
  exports = window.mixins = {}

mixins = exports

mixins.version = '1.0.1'

mixins.CAMEL_CASE = 'camel'
mixins.SNAKE_CASE = 'snake'

mixins.deprecated = (message) ->
  parseLine = (line) ->
    if line.indexOf('@') > 0
      if line.indexOf('</') > 0
        [m, o, f] = /<\/([^@]+)@(.)+$/.exec line
      else
        [m, f] = /@(.)+$/.exec line
    else
      if line.indexOf('(') > 0
        [m, o, f] = /at\s+([^\s]+)\s*\(([^\)])+/.exec line
      else
        [m, f] = /at\s+([^\s]+)/.exec line

    [o,f]

  e = new Error()
  caller = ''
  if e.stack?
    s = e.stack.split('\n')
    [deprecatedMethodCallerName, deprecatedMethodCallerFile] = parseLine s[3]

    caller = if deprecatedMethodCallerName
      " (called from #{deprecatedMethodCallerName} at #{deprecatedMethodCallerFile})"
    else
       "(called from #{deprecatedMethodCallerFile})"

  console.log "DEPRECATION WARNING: #{message}#{caller}"

mixins.deprecated._name = 'deprecated'


unless Object.getPropertyDescriptor?
  if Object.getPrototypeOf? and Object.getOwnPropertyDescriptor?
    Object.getPropertyDescriptor = (o, name) ->
      proto = o
      descriptor = undefined
      proto = Object.getPrototypeOf?(proto) or proto.__proto__ while proto and not (descriptor = Object.getOwnPropertyDescriptor(proto, name))
      descriptor
  else
    Object.getPropertyDescriptor = -> undefined


##### Function::accessor
#
# Creates a virtual property on the current class's prototype.
#
#     class Dummy
#       @accessor 'foo', {
#         get: -> @fooValue * 2
#         set: (value) -> @fooValue = value / 2
#       }
#
#     dummy = new Dummy
#     dummy.foo = 10
#     dummy.fooValue # 5
#     dummy.foo      # 10
Function::accessor = (name, options) ->
  oldDescriptor = Object.getPropertyDescriptor @prototype, name

  options.get ||= oldDescriptor.get if oldDescriptor?
  options.set ||= oldDescriptor.set if oldDescriptor?

  Object.defineProperty @prototype, name, {
    get: options.get
    set: options.set
    configurable: true
    enumerable: true
  }
  this

##### Function::getter
#
# Creates a getter on the given class prototype
#
#     class Dummy
#       @getter 'foo', -> 'bar'
Function::getter = (name, block) -> @accessor name, get: block

##### Function::setter
#
# Creates a setter on the given class prototype
#
#     class Dummy
#       @setter 'foo', (value) -> @fooValue = value / 2
Function::setter = (name, block) -> @accessor name, set: block

##### registerSuper
#
# This method registers a method as the super method for another
# method for the given class.
# The super methods are stored in a map structure where the `__included__`
# array stores the keys and the `__super__` array stores the values.
# A meaningful name is added to the function to know its origin.
registerSuper = (key, value, klass, sup, mixin) ->
  return if value.__included__? and klass in value.__included__

  value.__super__ ||= []
  value.__super__.push sup

  value.__included__ ||= []
  value.__included__.push klass

  value.__name__ = sup.__name__ = "#{mixin.name}::#{key}"

##### findCaller
#
# For a given function on an object it will find the property
# name and its kind (value/getter/setter).
findCaller = (caller, proto) ->
  keys = Object.keys proto

  for k in keys
    descriptor = Object.getPropertyDescriptor proto, k

    if descriptor?
      return {key: k, descriptor, kind: 'value'} if descriptor.value is caller
      return {key: k, descriptor, kind: 'get'} if descriptor.get is caller
      return {key: k, descriptor, kind: 'set'} if descriptor.set is caller
    else
      return {key: k} if proto[k] is caller

  {}

##### addPrototypeSuperMethod
#
# Creates the `super` method on the given prototype.
addPrototypeSuperMethod = (target) ->
  ##### Object::super
  #
  # When a mixin is included into a class, a `super` method
  # is created on its prototype. It will allow the instances
  # and mixins methods to have access to their super methods.
  unless target.super?
    target.super = (args...) ->
      # To define which function to use as super when
      # calling the `this.super` method we need to know which
      # function is the caller.
      caller = arguments.caller or @super.caller
      if caller?
        # When the caller has a `__super__` property, we face
        # a mixin method, we can access the `__super__` property
        # to retrieve its super property.
        if caller.__super__?
          value = caller.__super__[caller.__included__.indexOf @constructor]

          # The `this.super` method can be called only if the super
          # is a function.
          if value?
            if typeof value is 'function'
              value.apply(this, args)
            else
              throw new Error "The super for #{caller._name} isn't a function"
          else
            throw new Error "No super method for #{caller._name}"

        # Without the `__super__` property we face a method declared
        # in the including class and that may redefine a method from
        # a mixin or a parent.
        else
          # The name of the property that stores the caller is retrieved.
          # The `kind` variable is either `'value'`, `'get'`, `'set'`
          # or `'null'`. It will be needed to find the correspondant
          # super method in the property descriptor.
          {key, kind} = findCaller caller, @constructor.prototype

          if key?
            # If the key is present we'll try to get a descriptor on the
            # `__super__` class property.
            desc = Object.getPropertyDescriptor @constructor.__super__, key
            if desc?
              # And if a descriptor is available we get the function
              # corresponding to the `kind` and call it with the arguments.
              value = desc[kind].apply(this, args)
            else
              # Otherwise, the value of the property is simply called.
              value = @constructor.__super__[key].apply(this, args)

            return value
          else
            # And in other cases an error is raised.
            throw new Error "No super method for #{caller.name || caller._name}"
      else
        throw new Error "Super called with a caller"

##### addClassSuperMethod
#
addClassSuperMethod = (o) ->
  unless o.super?
    o.super = (args...) ->
      caller = arguments.caller or @super.caller
      if caller?
        if caller.__super__?
          value = caller.__super__[caller.__included__.indexOf this]

          if value?
            if typeof value is 'function'
              value.apply(this, args)
            else
              throw new Error "The super for #{caller._name} isn't a function"
          else
            throw new Error "No super method for #{caller._name}"

        else
          # super method in the property descriptor.
          {key, kind} = findCaller caller, this

          reverseMixins = []
          reverseMixins.unshift m for m in @__mixins__

          if key?
            # If the key is present we'll try to get a descriptor on the
            # `__super__` class property.
            mixin = m for m in reverseMixins when m[key]?

            desc = Object.getPropertyDescriptor mixin, key
            if desc?
              # And if a descriptor is available we get the function
              # corresponding to the `kind` and call it with the arguments.
              value = desc[kind].apply(this, args)
            else
              # Otherwise, the value of the property is simply called.
              value = mixin[key].apply(this, args)

            return value
          else
            # And in other cases an error is raised.
            throw new Error "No super method for #{caller.name || caller._name}"
      else
        throw new Error "Super called with a caller"


##### Function::include
#
# The `include` method inject the properties from the mixins
# prototype into the target prototype.
Function::include = (mixins...) ->
  # The mixins prototype constructor and excluded properties
  # are always excluded.
  excluded = ['constructor', 'excluded', 'super']

  # The `__mixins__` class property will stores the mixins included
  # in the current class.
  @__mixins__ ||= []

  # The `__super__` class property is used in CoffeeScript to store
  # the parent class prototype when the `extend` keyword is used.
  #
  # It'll be used to store the super methods from mixins so we create
  # one to use as default if we can't find it.
  @__super__ ||= {}

  # We create a new `__super__` using the previous one as prototype.
  # It allow to have mixins overrides some properties already defined
  # by a parent prototype without actually modifying this prototype.
  @__super__ = Object.create @__super__


  # For each mixin passed to the `include` class method:
  for mixin in mixins
    # We'll store the mixin in the `__mixins__` array to keep track of
    # its inclusion.
    @__mixins__.push mixin

    # A new Array is created to store the exclusion list of the current
    # mixin. It is based on the default exclusion array.
    excl = excluded.concat()
    excl = excl.concat mixin::excluded if mixin::excluded?

    # Adds the `super` method on the prototype
    addPrototypeSuperMethod @prototype

    # We loop through all the enumerable properties of the mixin's
    # prototype.
    keys = Object.keys mixin.prototype
    for k in keys
      if k not in excl

        # We prefer working with property descriptors rather than with
        # the plain value.
        oldDescriptor = Object.getPropertyDescriptor @prototype, k
        newDescriptor = Object.getPropertyDescriptor mixin.prototype, k

        # If the two descriptors are available we'll have to go deeper.
        if oldDescriptor? and newDescriptor?
          oldHasAccessor = oldDescriptor.get? or oldDescriptor.set?
          newHasAccessor = newDescriptor.get? or newDescriptor.set?
          bothHaveGet = oldDescriptor.get? and newDescriptor.get?
          bothHaveSet = oldDescriptor.set? and newDescriptor.set?
          bothHaveValue = oldDescriptor.value? and newDescriptor.value?

          # When both properties are accessors we'll be able to follow
          # the super accross them
          if oldHasAccessor and newHasAccessor
            # Super methods are registered if both are there for getters
            # and setters.
            registerSuper k, newDescriptor.get, @, oldDescriptor.get, mixin if bothHaveGet
            registerSuper k, newDescriptor.set, @, oldDescriptor.set, mixin if bothHaveSet

            # If there was a getter or a setter and the new accessor
            # doesn't define one them, the previous value is used.
            newDescriptor.get ||= oldDescriptor.get
            newDescriptor.set ||= oldDescriptor.set

          # When both have a value, the super is also available.
          else if bothHaveValue
            registerSuper k, newDescriptor.value, @, oldDescriptor.value, mixin

          else
            throw new Error "Can't mix accessors and plain values inheritance"

          # We also have to create the property on the class `__super__`
          # property. It'll allow the method defined on the class itself
          # and overriding the property to have access to its super property
          # through the `super` keyword or with `this.super` method.
          Object.defineProperty @__super__, k, newDescriptor

        # We only have a descriptor for the new property, the previous
        # one is just added to the class `__super__` property.
        else if newDescriptor?
          @__super__[k] = mixin[k]

        # We only have a descriptor for the previous property, we'll
        # create it on the class `__super__` property.
        else if oldDescriptor?
          Object.defineProperty @__super__, k, newDescriptor

        # No descriptors at all. The super property is attached directly
        # to the value.
        else if @::[k]?
          registerSuper k, mixin[k], @, @::[k], mixin
          @__super__[k] = mixin[k]

        # With a descriptor the new property is created using
        # `Object.defineProperty` or by affecting the value
        # to the prototype.
        if newDescriptor?
          Object.defineProperty @prototype, k, newDescriptor
        else
          @::[k] = mixin::[k]

    # The `included` hook is triggered on the mixin.
    mixin.included? this

  this

Function::extend = (mixins...) ->
  excluded = ['extended', 'excluded', 'included']

  # The `__mixins__` class property will stores the mixins included
  # in the current class.
  @__mixins__ ||= []

  for mixin in mixins
    @__mixins__.push mixin

    excl = excluded.concat()
    excl = excl.concat mixin.excluded if mixin.excluded?

    addClassSuperMethod this

    keys = Object.keys mixin
    for k in keys
      if k not in excl
        oldDescriptor = Object.getPropertyDescriptor this, k
        newDescriptor = Object.getPropertyDescriptor mixin, k

        if oldDescriptor? and newDescriptor?
          oldHasAccessor = oldDescriptor.get? or oldDescriptor.set?
          newHasAccessor = newDescriptor.get? or newDescriptor.set?
          bothHaveGet = oldDescriptor.get? and newDescriptor.get?
          bothHaveSet = oldDescriptor.set? and newDescriptor.set?
          bothHaveValue = oldDescriptor.value? and newDescriptor.value?

          # When both properties are accessors we'll be able to follow
          # the super accross them
          if oldHasAccessor and newHasAccessor
            # Super methods are registered if both are there for getters
            # and setters.
            registerSuper k, newDescriptor.get, @, oldDescriptor.get, mixin if bothHaveGet
            registerSuper k, newDescriptor.set, @, oldDescriptor.set, mixin if bothHaveSet

            # If there was a getter or a setter and the new accessor
            # doesn't define one them, the previous value is used.
            newDescriptor.get ||= oldDescriptor.get
            newDescriptor.set ||= oldDescriptor.set

          # When both have a value, the super is also available.
          else if bothHaveValue
            registerSuper k, newDescriptor.value, @, oldDescriptor.value, mixin

          else
            throw new Error "Can't mix accessors and plain values inheritance"

        # With a descriptor the new property is created using
        # `Object.defineProperty` or by affecting the value
        # to the prototype.
        if newDescriptor?
          Object.defineProperty this, k, newDescriptor
        else
          @[k] = mixin[k]

    mixin.extended? this

  this

Function::concern = (mixins...) ->
  @include.apply(this, mixins)
  @extend.apply(this, mixins)


# The `Aliasable` mixin provides the `alias` method in extended classes.
#
#     class Dummy
#       @extend mixins.Aliasable
#
#       someMethod: ->
#       @alias 'someMethod', 'someMethodAlias'
class mixins.Aliasable
  ##### Aliasable.alias
  #
  # Creates aliases for the given `source` property of tthe current
  # class prototype. Any number of alias can be passed at once.
  @alias: (source, aliases...) ->
    desc = Object.getPropertyDescriptor @prototype, source

    if desc?
      Object.defineProperty @prototype, alias, desc for alias in aliases
    else
      if @prototype[ source ]?
        @prototype[ alias ] = @prototype[ source ] for alias in aliases


# The `AlternateMixin` mixin add methods to convert the properties
# of a class instance to camelCase or snake_case.
#
# The methods are available on the class itself and should be called
# after having declared all the class members.
#
# For instance, given the class below:
#
#     class Dummy
#       @extend mixins.AlternateCase
#
#       someProperty: 'foo'
#       someMethod: ->
#
#       @snakify()
#
# An instance will have both `someProperty` and `someMethod` as defined
# by the class, but also `some_property` and `some_method`.
#
# The alternative is also possible. Given a class that uses snake_case
# to declare its member, the `camelize` method will provides the camelCase
# alternative to the class.
class mixins.AlternateCase

  ##### AlternateCase.toSnakeCase

  # Converts a string to snake_case.
  @toSnakeCase: (str) ->
    str.
    replace(/([a-z])([A-Z])/g, "$1_$2")
    .split(/_+/g)
    .join('_')
    .toLowerCase()

  # Converts a string to camelCase.
  @toCamelCase: (str) ->
    a = str.toLowerCase().split(/[_\s-]/)
    s = a.shift()
    s = "#{ s }#{ utils.capitalize w }" for w in a
    s

  # Adds the specified alternatives of each properties on the current
  # prototype. The passed-in argument is the name of the class method
  # to call to convert the key string.
  @convert: (alternateCase) ->
    for key,value of @prototype
      alternate = @[alternateCase] key

      descriptor = Object.getPropertyDescriptor @prototype, key

      if descriptor?
        Object.defineProperty @prototype, alternate, descriptor
      else
        @prototype[alternate] = value

  # Converts all the prototype properties to snake_case.
  @snakify: -> @convert 'toSnakeCase'

  # Converts all the prototype properties to camelCase.
  @camelize: -> @convert 'toCamelCase'


#### Build

# Contains all the function that will instanciate a class with a specific
# number of arguments. These functions are all generated at runtime with
# the `Function` constructor.
BUILDS = (
  new Function( "return new arguments[0](#{
    ("arguments[1][#{ j-1 }]" for j in [ 0..i ] when j isnt 0).join ","
  });") for i in [ 0..24 ]
)

build = (klass, args) ->
  f = BUILDS[ if args? then args.length else 0 ]
  f klass, args

#### Cloneable

# A `Cloneable` object can return a copy of itself through the `clone`
# method.
#
# The `Cloneable` function produce a different mixin when called
# with or without arguments.
#
# When called without argument, the returned mixin creates a clone using
# a copy constructor (a constructor that initialize the current object
# with an object).
#
#     class Dummy
#       @include mixins.Cloneable()
#
#       constructor: (options={}) ->
#         @property = options.property or 'foo'
#         @otherProperty = options.otherProperty or 'bar'
#
#     instance = new Dummy
#     otherInstance = instance.clone()
#     # otherInstance = {property: 'foo', otherProperty: 'bar'}
#
# When called with arguments, the `clone` method will call the class
# constructor with the values extracted from the given properties.
#
#     class Dummy
#       @include mixins.Cloneable('property', 'otherProperty')
#
#       constructor: (@property='foo', @otherProperty='bar') ->
#
#     instance = new Dummy
#     otherInstance = instance.clone()
#     # otherInstance = {property: 'foo', otherProperty: 'bar'}
mixins.Cloneable = (properties...) ->
  class ConcreteCloneable
    if properties.length is 0
      @included: (klass) -> klass::clone = -> new klass this
    else
      @included: (klass) -> klass::clone = -> build klass, properties.map (p) => @[ p ]

mixins.Cloneable._name = 'Cloneable'


# The `Delegation` mixin allow to define properties on an object that
# proxy another property of an object stored in one of its property
#
#     class Dummy
#       @extend Delegation
#
#       @delegate 'someProperty', to: 'someObject'
#
#       constructor: ->
#         @someObject = someProperty: 'some value'
#
#     instance = new Dummy
#     instance.someProperty
#     # 'some value'
class mixins.Delegation

  ##### Delegation.delegate

  # The `delegate` class method generates a property on the current
  # prototype that proxy the property of the given object.
  #
  # The `to` option specify the property of the object accessed by
  # the delegated property.
  #
  # The delegated property name can be prefixed with the name of the
  # accessed property
  #
  #     class Dummy
  #       @extend Delegation
  #
  #       @delegate 'someProperty', to: 'someObject', prefix: true
  #       # delegated property is named `someObjectSomeProperty`
  #
  # By default, using a prefix generates a camelCase property name.
  # You can use the `case` option to change that to a snake_case property
  # name.
  #
  #     class Dummy
  #       @extend Delegation
  #
  #       @delegate 'some_property', to: 'some_object', prefix: true
  #       # delegated property is named `some_object_some_property`
  #
  # The `delegate` method accept any number of properties to delegate
  # with the same options.
  #
  #     class Dummy
  #       @extend Delegation
  #
  #       @delegate 'someProperty', 'someOtherProperty', to: 'someObject'
  @delegate: (properties..., options={}) ->
    delegated = options.to
    prefixed = options.prefix
    _case = options.case or mixins.CAMEL_CASE

    properties.forEach (property) =>
      localAlias = property

      # Currently, only `camel`, and `snake` cases are supported.
      if prefixed
        switch _case
          when mixins.SNAKE_CASE
            localAlias = delegated + '_' + property
          when mixins.CAMEL_CASE
            localAlias = delegated + property.replace /^./, (m) ->
              m.toUpperCase()

      # The `Delegation` mixin rely on `Object.property` and thus can't
      # be used on IE8.
      Object.defineProperty @prototype, localAlias, {
        enumerable: true
        configurable: true
        get: -> @[ delegated ][ property ]
        set: (value) -> @[ delegated ][ property ] = value
      }


# An `Equatable` object can be compared in equality with another object.
# Objects are considered as equal if all the listed properties are equal.
#
#     class Dummy
#       @include mixins.Equatable('p1', 'p2')
#
#       constructor: (@p1, @p2) ->
#         # ...
#
#     dummy = new Dummy(10, 'foo')
#     dummy.equals p1: 10, p2: 'foo'   # true
#     dummy.equals new Dummy(5, 'bar') # false
#
# The `Equatable` mixin is called a parameterized mixin as
# it's in fact a function that will generate a mixin based
# on its arguments.
mixins.Equatable = (properties...) ->

  # A concrete class is generated and returned by `Equatable`.
  # This class extends `Mixin` and can be attached as any other
  # mixin with the `attachTo` method.
  class ConcreteEquatable

    ##### Equatable::equals
    #
    # Compares the `properties` of the passed-in object with the current
    # object and return `true` if all the values are equal.
    equals: (o) -> o? and properties.every (p) =>
      if @[ p ].equals? then @[ p ].equals o[ p ] else o[p] is @[ p ]

mixins.Equatable._name = 'Equatable'


# A `Formattable` object provides a `toString` that return
# a string representation of the current instance.
#
#     class Dummy
#       @include mixins.Formattable('Dummy', 'p1', 'p2')
#
#       constructor: (@p1, @p2) ->
#         # ...
#
#     dummy = new Dummy(10, 'foo')
#     dummy.toString()
#     # [Dummy(p1=10, p2=foo)]
#
# You may wonder why the class name is passed in the `Formattable`
# call, the reason is that javascript minification can alter the
# naming of the functions and in that case, the constructor function
# name can't be relied on anymore.
# Passing the class name will ensure that the initial class name
# is always accessible through an instance.
mixins.Formattable = (classname, properties...) ->
  #
  class ConcretFormattable
    ##### Formattable::toString
    #
    # Returns the string reprensentation of this instance.
    if properties.length is 0
      ConcretFormattable::toString = ->
        "[#{ classname }]"
    else
      ConcretFormattable::toString = ->
        formattedProperties = ("#{ p }=#{ @[ p ] }" for p in properties)
        "[#{ classname }(#{ formattedProperties.join ', ' })]"

    ##### Formattable::classname
    #
    # Returns the class name of this instance.
    classname: -> classname

mixins.Formattable._name = 'Formattable'


# The list of properties that are unglobalizable by default.
DEFAULT_UNGLOBALIZABLE = [
  'globalizable'
  'unglobalizable'
  'globalized'
  'globalize'
  'unglobalize'
  'globalizeMember'
  'unglobalizeMember'
  'keepContext'
  'previousValues'
  'previousDescriptors'
]

# A `Globalizable` object can expose some methods on the specified global
# object (`window` in a browser or `global` in nodejs when using methods
# from the `vm` module).
#
# The *globalization* process is reversible and take care to preserve
# the initial properties of the global that may be overriden.
#
# The properties exposed on the global object are defined
# in the `globalizable` property.
#
#     class Dummy
#       @include mixins.Globalizable window
#
#       globalizable: ['someMethod']
#
#       someMethod: -> console.log 'in some method'
#
#     instance = new Dummy
#     instance.globalize()
#
#     someMethod()
#     # output: 'in some method'
#
# The process can be reversed with the `unglobalize` method.
#
#     instance.unglobalize()
#
# The `Globalizable` function takes the target global object as the first
# argument. The second argument define whether the functions on
# a globalized object are bound to this object or to the global object.
mixins.Globalizable = (global, keepContext=true) ->
  class ConcreteGlobalizable

    @unglobalizable: DEFAULT_UNGLOBALIZABLE.concat()

    keepContext: keepContext

    #####  Globalizable::globalize
    #
    # The method that actually exposes the object methods on global.
    globalize: ->
      # But only if the object isn't already `globalized`.
      return if @globalized

      # Creates the objects that will stores the previous values
      # and property descriptors present on `global` before the
      # object globalization.
      @previousValues = {}
      @previousDescriptors = {}

      # Then for each properties set for globalization the
      # `globalizeMember` method is called.
      @globalizable.forEach (k) =>
        unless k in (@constructor.unglobalizable or ConcreteGlobalizable.unglobalizable)
          @globalizeMember k

      # And the object is marked as `globalized`.
      @globalized = true

    ##### Globalizable::unglobalize
    #
    # The reverse process of `globalize`.
    unglobalize: ->
      return unless @globalized

      # For each properties set for globalization the
      # `unglobalizeMember` method is called.
      @globalizable.forEach (k) =>
        unless k in (@constructor.unglobalizable or ConcreteGlobalizable.unglobalizable)
          @unglobalizeMember k

      # And then the object is cleaned of the globalization artifacts
      # and the `globalized` mark is removed.
      @previousValues = null
      @previousDescriptors = null
      @globalized = false

    ##### Globalizable::globalizeMember
    #
    # Exposes a member of the current object on global.
    globalizeMember: (key) ->
      # If possible we prefer using property descriptors rather than
      # accessing directly the properties. It will allow to correctly
      # expose virtual properties (get/set) created through
      # `Object.defineProperty`.
      oldDescriptor = Object.getPropertyDescriptor global, key
      selfDescriptor = Object.getPropertyDescriptor this, key

      # If we have a property descriptor for the previous global property
      # we store it to restore it in the `unglobalize` process.
      if oldDescriptor?
        @previousDescriptors[ key ] = oldDescriptor
      # Otherwise the property value is stored.
      else if @[ key ]?
        @previousValues[ key ] = global if global[ key ]?

      # If we have a property descriptor for the object property, we'll
      # use it to create the property on global with the same settings.
      if selfDescriptor?
        # But if we have to bind functions to the object there'll be
        # a need for additional setup.
        if keepContext
          # For instance, if the descriptor contains a `get` and `set`
          # property then we have to bind both.
          if selfDescriptor.get? or selfDescriptor.set?
            selfDescriptor.get = selfDescriptor.get?.bind(@)
            selfDescriptor.set = selfDescriptor.set?.bind(@)
          # Otherwise, if the value is a function we bind it.
          else if typeof selfDescriptor.value is 'function'
            selfDescriptor.value = selfDescriptor.value.bind(@)

        # Finally the descriptor is used to create the new property
        # on the global object.
        Object.defineProperty global, key, selfDescriptor

      # Without a property descriptor for the object's property
      # the value is retreived and used to create a new property
      # descriptor.
      else
        value = @[ key ]
        value = value.bind(@) if typeof value is 'function' and keepContext
        Object.defineProperty global, key, {
          value
          enumerable: true
          writable: true
          configurable: true
        }

    ##### Globalizable::unglobalizeMember
    #
    # The inverse process of `globalizeMember`.
    unglobalizeMember: (key) ->
      # If we have a previous descriptor we restore ot on global.
      if @previousDescriptors[ key ]?
        Object.defineProperty global, key, @previousDescriptors[ key ]

      # If there's no previous descriptor but a previous value,
      # the value is affected to the global property.
      else if @previousValues[ key ]?
        global[ key ] = @previousValues[ key ]

      # And if there's nothing the property is unset.
      else
        global[ key ] = undefined

mixins.Globalizable._name = 'Globalizable'






# The `HasAncestors` mixin adds several methods to instance to deal
# with parents and ancestors.
#
#     class Dummy
#       @concern mixins.HasAncestors through: 'parentNode'
#
# The `through` option allow to specify the property name that access
# to the parent.
mixins.HasAncestors = (options={}) ->
  through = options.through or 'parent'

  class ConcreteHasAncestors
    ##### HasAncestors::ancestors
    #
    # Returns an array of all the ancestors of the current object.
    # The ancestors are ordered such as the first element is the direct
    # parent of the current object.
    @getter 'ancestors', ->
      ancestors = []
      parent = @[ through ]

      while parent?
        ancestors.push parent
        parent = parent[ through ]

      ancestors

    ##### HasAncestors::selfAndAncestors
    #
    # Returns an object containing the current object followed by its
    # parent and ancestors.
    @getter 'selfAndAncestors', -> [ this ].concat @ancestors

    ##### HasAncestors.ancestorsScope
    #
    # Defines a getter property on instances named with `name` and that
    # filter the `ancestors` array with the given `block`.
    @ancestorsScope: (name, block) ->
      @getter name, -> @ancestors.filter(block, this)

mixins.HasAncestors._name = 'HasAncestors'


# The `HasCollection` mixin provides methods to expose a collection
# in a class. The mixin is created using two strings.
#
#     class Dummy
#       @concern mixins.HasCollection 'children', 'child'
#
#       constructor: ->
#         @children = []
#
# The `plural` string is used to access the collection in all methods
# provided by the mixin. The `singular` string will be used to create
# the collection managing methods.
#
# For instance, given that `'children'` and `'child'` was passed as arguments
# to `HasCollection` the following methods and properties will be created:
#
#    - childrenSize [getter]
#    - childrenCount [getter]
#    - childrenLength [getter]
#    - hasChildren [getter]
#    - addChild
#    - removeChild
#    - hasChild
#    - containsChild
mixins.HasCollection = (plural, singular) ->

  pluralPostfix = plural.replace /^./, (s) -> s.toUpperCase()
  singularPostfix = singular.replace /^./, (s) -> s.toUpperCase()

  class ConcreteHasCollection
    # The mixin integrates `Aliasable` to create various alias to the
    # collection methods.
    @extend mixins.Aliasable

    ##### HasCollection.&lt;items&gt;Scope
    #
    # Creates a `name` property on instances that filter the collection
    # using the passed-in `block`.
    @[ "#{ plural }Scope" ] = (name, block) ->
      @getter name, -> @[ plural ].filter block, this

    ##### HasCollection::&lt;items&gt;Size
    #
    # A property returning the number of elements in the collection.
    @getter "#{ plural }Size", -> @[ plural ].length

    # Creates aliases for the collection size property.
    @alias "#{ plural }Size", "#{ plural }Length", "#{ plural }Count"

    ##### HasCollection::has&lt;Item&gt;
    #
    # Returns `true` if the passed-in `item` is present in the collection.
    @::[ "has#{ singularPostfix }" ] = (item) -> item in @[ plural ]

    # Creates an alias for `has<Item>` named `contains<Item>`.
    @alias "has#{ singularPostfix }", "contains#{ singularPostfix }"

    ##### HasCollection::has&lt;Items&gt;
    #
    # Returns `true` if the collection has at least one item.
    @getter "has#{ pluralPostfix }", -> @[ plural ].length > 0

    ##### HasCollection::add&lt;Item&gt;
    #
    # Adds `item` in the collection unless it's already present.
    @::[ "add#{ singularPostfix }" ] = (item) ->
      @[ plural ].push item unless @[ "has#{ singularPostfix }" ] item

    ##### HasCollection::remove&lt;Item&gt;
    #
    # Removes `item` from the collection.
    @::[ "remove#{ singularPostfix }" ] = (item) ->
      if @[ "has#{ singularPostfix }" ] item
        @[ plural ].splice @[ "find#{ singularPostfix }" ](item), 1

    ##### HasCollection::find&lt;Item&gt;
    #
    # Retuns the index at which `item` is stored in the collection.
    # It returns `-1` if `item` can't be found.
    @::[ "find#{ singularPostfix }" ] = (item) -> @[ plural ].indexOf item

    # Creates an alias for `find<Item>` named `indexOf<Item>`
    @alias "find#{ singularPostfix }", "indexOf#{ singularPostfix }"

mixins.HasCollection._name = 'HasCollection'


# The `HasNestedCollection` adds a property with named `name` that
# collects and concatenates all the descendants collections into a
# single array.
# It operates on classes that already includes the `HasCollection` mixin.
#
#     class Dummy
#       @concern mixins.HasCollection 'children', 'child'
#       @concern mixins.HasNestedCollection 'descendants', through: 'children'
#
#       constructor: ->
#         @children = []
#
mixins.HasNestedCollection = (name, options={}) ->

  # The collection is accessed with the named passed in the `through`option.
  through = options.through
  throw new Error('missing through option') unless through?

  class ConcreteHasNestedCollection
    ##### HasNestedCollection::&lt;name&gt;Scope
    #
    # Creates a property on instances that filters the nested collections
    # items using the passed-in `block`.
    @[ "#{ name }Scope" ] = (scopeName, block) ->
      @getter scopeName, -> @[ name ].filter block, this

    ##### HasCollection::&lt;name&gt;
    #
    # Returns a flat array containing all the items contained in all the
    # nested collections.
    @getter name, ->
      items = []
      @[ through ].forEach (item) ->
        items.push(item)
        items = items.concat(item[ name ]) if item[ name ]?
      items

mixins.HasNestedCollection._name = 'HasNestedCollection'



# A `Memoizable` object can store data resulting of heavy methods
# in order to speed up further call to that method.
#
# The invalidation of the memoized data is defined using a `memoizationKey`.
# That key should be generated based on the data that may induce changes
# in the functions's results.
#
#     class Dummy
#       @include mixins.Memoizable
#
#       constructor: (@p1, @p2) ->
#         # ...
#
#       heavyMethod: (arg) ->
#         key = "heavyMethod-#{arg}"
#         return @memoFor key if @memoized key
#
#         # do costly computation
#         @memoize key, result
#
#       memoizationKey: -> "#{p1};#{p2}"
class mixins.Memoizable
  ##### Memoizable::memoized
  #
  # Returns `true` if data are available for the given `prop`.
  #
  # When the current state of the object don't match the stored
  # memoization key, the whole data stored in the memo are cleared.
  memoized: (prop) ->
    if @memoizationKey() is @__memoizationKey__
      @__memo__?[ prop ]?
    else
      @__memo__ = {}
      false

  ##### Memoizable::memoFor
  #
  # Returns the memoized data for the given `prop`.
  memoFor: (prop) -> @__memo__[ prop ]

  ##### Memoizable::memoize
  #
  # Register a memo in the current object for the given `prop`.
  # The memoization key is updated with the current state of the
  # object.
  memoize: (prop, value) ->
    @__memo__ ||= {}
    @__memoizationKey__ = @memoizationKey()
    @__memo__[ prop ] = value

  ##### Memoizable::memoizationKey
  #
  # **Virtual Method**
  #
  # Generates the memoization key for this instance's state.
  memoizationKey: -> @toString()



#
mixins.Parameterizable = (method, parameters, allowPartial=false) ->
  #
  class ConcreteParameterizable

    ##### Parameterizable.included
    #
    @included: (klass) ->
      f = (args..., strict)->
        (args.push(strict); strict = false) if typeof strict is 'number'
        output = {}

        o = arguments[ 0 ]
        n = 0
        firstArgumentIsObject = o? and typeof o is 'object'

        for k,v of parameters
          value = if firstArgumentIsObject then o[ k ] else arguments[ n++ ]
          output[ k ] = parseFloat value

          if isNaN output[ k ]
            if strict
              keys = (k for k in parameters).join ', '
              throw new Error "#{ output } doesn't match pattern {#{ keys }}"
            if allowPartial then delete output[ k ] else output[ k ] = v

        output

      klass[method] = f
      klass::[method] = f

mixins.Parameterizable._name = 'Parameterizable'


#
class mixins.Poolable

  #### Poolable.extended

  # The two objects stores are created in the extended hook to avoid
  # that all the class extending `Poolable` shares the same instances.
  @extended: (klass) ->
    klass.usedInstances = []
    klass.unusedInstances = []

  #### Poolable.get

  # The `get` method returns an instance of the class.
  @get: (options={}) ->
    # Either retrieve or create the instance.
    if @unusedInstances.length > 0
      instance = @unusedInstances.shift()
    else
      instance = new this

    # Stores the instance in the used pool.
    @usedInstances.push instance

    # Init the instance and return it.
    instance.init(options)
    instance

  #### Poolable.release

  # The `release` method takes an instance and move it from the
  # the used pool to the unused pool.
  @release: (instance) ->
    # We can't release unused instances created using
    # the `new` operator without using `get`.
    unless instance in @usedInstances
      throw new Error "Can't release an unused instance"

    # The instance is removed from the used instances pool.
    index = @usedInstances.indexOf(instance)
    @usedInstances.splice(index, 1)

    # And then moved to the unused instances one.
    @unusedInstances.push instance

  #### Poolable::init

  # Default `init` implementation, just copy all the options
  # in the instance.
  init: (options={}) -> @[ k ] = v for k,v of options

  #### Poolable::dispose

  # Default `dispose` implementation, call the `release` method
  # on the instance constructor. A proper implementation should
  # take care of removing/cleaning all the instance properties.
  dispose: -> @constructor.release(this)


# A `Sourcable` object is an object that can return the source code
# to re-create it by code.
#
#     class Dummy
#       @include mixins.Sourcable('geomjs.Dummy', 'p1', 'p2')
#
#       constructor: (@p1, @p2) ->
#
#     dummy = new Dummy(10,'foo')
#     dummy.toSource() # "new geomjs.Dummy(10,'foo')"
mixins.Sourcable = (name, signature...) ->

  # A concrete class is generated and returned by `Sourcable`.
  # This class extends `Mixin` and can be attached as any other
  # mixin with the `attachTo` method.
  class ConcreteSourcable
    #
    sourceFor = (value) ->
      switch typeof value
        when 'object'
          isArray = Object::toString.call(value).indexOf('Array') isnt -1
          if isArray
            "[#{ value.map (el) -> sourceFor el }]"
          else
            if value.toSource?
              value.toSource()
            else
              value
        when 'string'
          "'#{ value.replace "'", "\\'" }'"
        else value

    ##### Sourcable::toSource
    #
    # Return the source code corresponding to the current instance.
    toSource: ->
      args = (@[ arg ] for arg in signature).map (o) -> sourceFor o

      "new #{ name }(#{ args.join ',' })"

mixins.Sourcable._name = 'Sourcable'
