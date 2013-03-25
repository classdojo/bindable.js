dref = require("dref")




  

module.exports = class DeepPropertyWatcher

  ###
  ###

  constructor: (@target, @property, @callback) ->
    @_chain = property.split(".")
    @_watch()

  ###
  ###

  dispose: () ->
    if @_listeners
      for listener in @_listeners
        listener.dispose()

      @_listeners = undefined


  ###
  ###

  _watch: () ->

    if @_listeners
      @dispose()

    @_listeners = []

    for part, i in @_chain

      property = @_chain.slice(0, i + 1).join(".")
      value = @target.get(property)

      # if the item is bindable, then we need to WATCH that bindable item for any changes. This is needed for when we have a case like this
      # bindable.bind("name.last", function() { });
      # bindable.get("name").set("last", "jefferds")
      if value and value.__isBindable
        @_listeners.push new DeepPropertyWatcher value, @_chain.slice(i + 1).join("."), @changed
      else
        @_listeners.push @target.on "change:#{property}", () => @changed()

  ###
  ###

  changed: () =>

    @callback()

    # re-create the bindings since shit could have changed
    @_watch()



