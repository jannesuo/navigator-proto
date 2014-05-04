# Adds a new leaflet control that shows a compass on the map
# It is a simple div with class 'leaflet-control-compass' that
# is rotated with css transofrmations according to device orientation.
L.Control.Compass = L.Control.extend
  options:
    position : 'topleft',
    title : 'Compass',
    frequency: 200

  onAdd: (map) ->
    $(document).on "deviceready", =>
      L.DomUtil.addClass @_container, 'leaflet-control-layers leaflet-control-compass'
      @_inner = L.DomUtil.create 'div', '', @_container
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
    
    # FIXME: avoid 360deg rotation when moving from 360 to 0 (or the other way);
    # at the moment it is patched removing temporarily the transition effect.
    delta = @_oldheading - degrees
    if L.DomUtil.TRANSFORM and L.DomUtil.TRANSITION
      @_inner.style[L.DomUtil.TRANSITION] = ""
      if delta < -180 or delta > 180
        @_inner.style[L.DomUtil.TRANSITION] = "none"
      @_inner.style[L.DomUtil.TRANSFORM] = " rotate(#{degrees}deg)"
      @_oldheading = degrees

  onError: (error) ->
    @removeFrom @_map

L.control.compass = (options) -> new L.Control.Compass(options)
