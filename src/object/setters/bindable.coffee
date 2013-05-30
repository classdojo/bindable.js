Base = require "./base"

module.exports = class extends Base
  
  ###
  ###

  constructor: (@binding, @to, @property) -> 
    super @binding

  ###
  ###

  now: () ->
    @_now = true
    super()
    @_bothWaysBinding?.now()


  ###
  ###

  _change: (value) ->
    @to.set @property, value

  ###
  ###

  dispose: () ->
    @_bothWaysBinding?.dispose()

    @_bothWaysBinding = 
    @binding = 
    @to = 
    @property = null

  ###
  ###

  bothWays: () ->
    # create a binding going the other way!
    @_bothWaysBinding = @to.bind(@property).to (value) =>
      return if @_value is value
      @_changeFrom value

    if @_now 
      @_bothWaysBinding.now()

  ###
  ###

  _changeFrom: (value) ->
    @binding._from.set @binding._property, @_value = @__transform "from", value

