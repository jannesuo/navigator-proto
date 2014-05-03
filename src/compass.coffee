L.Control.Compass = L.Control.extend
  options:
    position : 'topleft',
    title : 'Compass',
    frequency: 200

  onAdd: (map) ->
    $(document).on "deviceready", =>
      L.DomUtil.addClass @_container, 'leaflet-control-compass'
      @_oldheading = 0
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
    delta = @_oldheading - degrees
    if L.DomUtil.TRANSFORM and L.DomUtil.TRANSITION
      @_container.style[L.DomUtil.TRANSITION] = ""
      if delta < -180 or delta > 180
        @_container.style[L.DomUtil.TRANSITION] = "none"
      @_container.style[L.DomUtil.TRANSFORM] = " rotate(#{degrees}deg)"
      @_oldheading = degrees

  onError: (error) ->
    @removeFrom @_map

L.control.compass = (options) -> new L.Control.Compass(options)
