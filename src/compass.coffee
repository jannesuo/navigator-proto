L.Control.Compass = L.Control.extend
  options:
    position : 'topleft',
    title : 'Compass',
    frequency: 200

  onAdd: (map) ->
    $(document).on "deviceready", =>
      L.DomUtil.addClass @_container, 'leaflet-control-compass'
      @_watchID = navigator.compass.watchHeading(
        (heading) => @onSuccess heading
        (error) => @onError error
        frequency: @options.frequency
      )
    L.DomUtil.create 'div', ''

  onRemove: (map) ->
    navigator.compass.clearWatch @_watchID

  onSuccess: (heading) ->
    degrees = 360 - heading.magneticHeading
    if L.DomUtil.TRANSFORM
      @_container.style[L.DomUtil.TRANSFORM] = " rotate(#{degrees}deg)"

  onError: (error) ->
    @removeFrom @_map

L.control.compass = (options) -> new L.Control.Compass(options)
