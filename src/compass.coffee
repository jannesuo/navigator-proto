# TODO Remove this dummy module used to demo when not in cordova
navigator.compass ?=
  watchHeading: (s, f, o) ->
    degrees = 0
    setInterval (-> s(magneticHeading: (degrees += Math.floor((Math.random() - 1/2) * 360/10)))), o.frequency
  clearWatch: (id) -> clearInterval(id)

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
    L.DomUtil.create 'div', (if @_unavailable then '' else 'leaflet-control-compass')

  onSuccess: (heading) ->
    degrees = 360 - heading.magneticHeading
    if L.DomUtil.TRANSFORM
      @_container.style[L.DomUtil.TRANSFORM] = " rotate(#{degrees}deg)"

  onError: (error) ->
    navigator.compass.clearWatch @_watchID
    if @_container then @removeFrom @_map
    else @_unavailable = true

L.control.compass = (options) -> new L.Control.Compass(options)
