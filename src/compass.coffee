navigator.compass ?=
  watchHeading: ->
  clearWatch: ->

L.Control.Compass = L.Control.extend
  options:
    position : 'topleft',
    title : 'Compass',
    frequency: 200

  onAdd: (map) ->
    @_watchID = navigator.compass.watchHeading(
      (heading) => @onSuccess heading
      (error) => @onError error
      frequency: @options.frequency
    )
    L.DomUtil.create 'div', 'leaflet-control-compass'

  onSuccess: (heading) ->
    degrees = 360 - heading.magneticHeading
    if L.DomUtil.TRANSFORM
      @_container.style[L.DomUtil.TRANSFORM] += " rotate(#{degrees}deg)"

  onError: (error) ->
    navigator.compass.clearWatch @_watchID
    @remove()

L.control.compass = (options) -> new L.Control.Compass(options)
