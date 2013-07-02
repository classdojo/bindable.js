type      = require("type-component")
options   = require("../utils/options")

class PropertyWatcher

  ###
  ###

  constructor: (options) ->
    @reset options

    
  ###
  ###

  reset: (options) ->

    @target     = options.target
    @watch      = options.watch
    @path       = options.path
    @index      = options.index
    @root       = options.root or @
    @delay      = options.delay
    @property   = @path[@index] 
    @callback   = options.callback
    @_children  = []
    @_bindings  = []
    @_value     = undefined
    @_watching  = false
    @_updating  = false
    @_disposed  = false

    # loop through the property?
    if @_each = @property.substr(0, 1) is "@"
      @property = @property.substr 1

    @_watch()


  ###
  ###

  value: () ->
    values = []
    @_addValues values
    return if values.length > 1 then values else values[0]

  ###
  ###

  _addValues: (values) ->

    unless @_children.length
      values.push @_value
      return

    for child in @_children
      child._addValues values

    undefined

  ###
  ###

  _dispose: () ->  
    @_disposed = true 
    @_listener?.dispose()
    @_listener = undefined
    binding.dispose() for binding in @_bindings
    child.dispose() for child in @_children
    @_children  = []
    @_bindings  = []

  ###
  ###

  dispose: () ->  
    @_dispose()
    propertyWatcher.add @

  ###
  ###

  _update: () ->
    unless ~@delay
      @_watch()
      @callback()
      return
      
    return if @_updating
    @_updating = true
    @_disposed = false
    setTimeout (() =>
      return if @_disposed # disposed
      @_watch()
      @callback()
    ), @delay

  ###
  ###

  _watch: () ->
    @_updating = false


    if @target
      if @target.__isBindable

        if (nt = @target.get()).__isBindable
          @target = nt

        @watch      = @target
        @childPath  = @path.slice(@index)
        @childIndex = 1
        value       = @target.get(@property)
      else
        value       = @target[@property]
        @childPath  = @path
        @childIndex = @index + 1
    else
      @childPath = @path
      @childIndex = @index + 1
    

    if @_listener
      @_dispose()


    @_value = value


    # value is a function? check if it's computed!
    if ((t = type(value)) is "function") and value.refs
      for ref in value.refs
        @_watchRef ref

    @_listener = @watch.on "change:#{@childPath.slice(0, @childIndex - 1).concat(@property).join(".")}", @_changed

    if @_each
      @_watchEachValue value, t
    else
      @_watchValue value

  ###
  ###

  _watchEachValue: (fnOrArray, t) ->

    # computed properties should always have a delay
    unless ~@root.delay
      @root.delay = options.computedDelay

    switch t
      when "function" then @_callEach fnOrArray
      when "array" then @_loopEach fnOrArray
      when "undefined" then return
      else throw Error "'@#{@_property}' is a #{t}. '@#{@_property}' must be either an array, or function."
    
  ###
   asynchronous
  ###

  _callEach: (fn) ->
    @_value = []
    fn.call @target, (value) => 
      @_value.push value
      @_watchValue value

  ###
   synchronous
  ###

  _loopEach: (values) ->
    for value in values
      @_watchValue value
    undefined

  ###
  ###

  _watchValue: (value) ->
    if @childIndex < @childPath.length
      @_children.push new PropertyWatcher { watch: @watch, target: value, path: @childPath, index: @childIndex, callback: @callback, root: @root, delay: @delay }

  ###
  ###

  _watchRef: (ref) ->
    @_bindings.push new PropertyWatcher { target: @target, path: ref.split("."), index: 0, callback: @_changed, delay: @delay }
 
  ###
  ###

  _changed: (@_value) =>
    @root._update()




#propertyWatcher = module.exports = poolParty
#  max: 100
#  factory: (options) -> new PropertyWatcher options
#  recycle: (watcher, options) -> watcher.reset options

module.exports = PropertyWatcher

