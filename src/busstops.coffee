
# Configurations
busStopsMaximumCountForResults = 5
busStopSearchDiameter = 1000
busStopsPageId = "#bus-stop-page"
busStopInfoPageId = "#bus-stop-info"
kutsuplusPageId = "#kutsuplus-page"
fetchBusStopsUrl = "http://www.pubtrans.it/hsl/stops"
fetchBusStopDataUrl = "http://www.pubtrans.it/hsl/reittiopas/departure-api"
fetchCoordinatesUrl = "api.reittiopas.fi/hsl/prod/"

# Global variables
busStopToShowId = ''
actionType = ""


###Gets coordinates from Google. And shows nearest bus stops ###
###Modified from https://mindfiremobile.wordpress.com/2013/11/29/getting-geo-coordinates-from-address-in-phonegap-application-using-google-api/   ###
getCoordinatesFromAddress = (address, onSuccessCallback) ->
    console.log("Getting coordinates for address: "+address)
    getGeocoder = new google.maps.Geocoder()
    getGeocoder.geocode( { 'address': address}, (results, status) ->
        if status == google.maps.GeocoderStatus.OK
            if results[0]
                latitude = results[0].geometry.location.lat()
                longitude = results[0].geometry.location.lng()
                console.log('Latitude : ' + latitude + ',' + 'Longitude : ' + longitude)
                onSuccessCallback(latitude, longitude)  
            else
                console.log('Unable to detect your coordinates.')
        else
             console.log('Unable to detect your coordinates.')
    )


### Function for sending a Kutsuplus SMS order message ###
sendKutsuplusMessage = (busStopIdDeparture, busStopIdDestination) ->
    
    confirmation = confirm("Do you want to order a Kutsuplus car to "+ busStopIdDestination +"? This can cost up to 40 euros.")
    messageInfo =
      phoneNumber: "+358440301091",
      textMessage: "KP " + busStopIdDeparture + " " + busStopIdDestination
    
    if confirmation
        sms.sendMessage(messageInfo,
          (message) ->
            console.log("SMS ticket purchased succesfully: " + message)
          (error) ->
            console.log("code: " + error.code + ", message: " + error.message)
        )
    else
        console.log("SMS ticket purchase cancelled.")
        
###
    Description: Fetch time estimations for single bus stop
    Parameters:
    * busStopId: id of the bus stop which information is fetched
    * onSuccessCallback(array of bus stops with properties): called when ajax call succeeds
    * onFailureCallback(error message) : called when error occurs
###
fetchTimeEstimationsForBusStop =  (busStopId, onSuccessCallback, onFailureCallback) ->
    parseBusStopData = (busStopData) ->
      if busStopData?
        ###
          rtime = real time estimation in epoch time (if available)
          time  = static time estimation
          line  = bus number (e.g. 550)

          Example item:
          dest : "Viikki"
          id : "2144001341"
          info : ""
          line : "506"
          route : "2506 2"
          rtime : 1429099344
          stop : "2222218"
          stopname : "Konemies"
          time : 1429099320
        ###
        busInfos = []
        for i, bus of busStopData
          busInfo = {}
          busInfo["line"] = bus.line
          busInfo["estimation"] = true
          if bus.rtime && bus.rtime != ''?
            busInfo["timeStamp"] = bus.rtime
            busInfo["estimation"] = false
          else
            busInfo["timeStamp"] = bus.time

          busInfos.push(busInfo)

        onSuccessCallback(busInfos)
      else
        empty = []
        onSuccessCallback(empty)
      return

    busStopOnError = (error) ->
      console.log("Error on fetch estimations for a bus stop: " + error)
      onFailureCallback("(Bus stop search failed)")
      return

    url = fetchBusStopDataUrl + "?stops%5B%5D=#{busStopId}"
    console.log("API call: " + url)
    $.ajax
      url: url
      dataType: "json"
      error: (jqXHR, textStatus, errorThrown) ->
        console.log("fetchTimeEstimationsForBusStop:error")
        busStopOnError(textStatus)
        return
      success: (data, textStatus, jqXHR) ->
        console.log("fetchTimeEstimationsForBusStop:success")
        console.log("JSON: " + JSON.stringify(data))
        parseBusStopData(data)
        return
    return
fetchNearestBusStopsByCoordinates = (latitude, longitude, onSuccessCallback, onFailureCallback) ->
      rad = busStopSearchDiameter
      max = busStopsMaximumCountForResults
      console.log("Position calculated for finding bus stops")
      url = fetchBusStopsUrl + "?lat=#{latitude}&lon=#{longitude}&rad=#{rad}&max=#{max}"
      console.log("API call: " + url)
      # get closest bus stops
      $.ajax
        type: "GET"
        url: url
        dataType: "json"
        error: (jqXHR, textStatus) ->
          console.log("fetchNearestBusStops:error")
          console.log("Error in nearest bus stop fetch: " + textStatus)
          onFailureCallback(textStatus)
          return

        success: (data) ->
          console.log("fetchNearestBusStops:success")
          console.log("JSON: " + JSON.stringify(data))
          json = JSON.parse(JSON.stringify(data))
          if json?
            if (json.count <= 0)
              console.log("No bus stops found")
              # "no near bus stops found"
              empty = []
              onSuccessCallback(empty)
            else
              busStops = []
              ###
              busStop.properties includes the following fields:
                id    = bus stop id as used in API queries
                code  = value that is visible in bus stops (e.g. E2217)
                type  = "bus" for buses
                name  = bus stop name (e.g. "Konemies")
                addr  = unspecific address (e.g. "Konemiehentie")
                lines = array of bus objects
                dist  = distance (in meters) to the stop

              results are ordered based on distance (shortest first)
              ###
              for i, busStop of json.features
                busStops.push(busStop.properties)

              onSuccessCallback(busStops)
          return
    
###
   Description: Fetch nearest bus stops by geolocation
   Parameters:
    * onSuccessCallback(array of bus stops with properties)
    * onFailureCallback(error message)
###
fetchNearestBusStops = (onSuccessCallback, onFailureCallback) ->
  console.log("Fetching bus stops...")
  locationQuerySucceeded = (position) ->
    if position?
      latitude = position.coords.latitude.toString()    #.replace(".", "").slice(0, 7)
      longitude = position.coords.longitude.toString()  #.replace(".", "").slice(0, 7)
      fetchNearestBusStopsByCoordinates(latitude, longitude, onSuccessCallback, onFailureCallback)
      
    else
      console.log("Couldn't acquire the current position")
      onFailureCallback("(Couldn't acquire the current position)")

    return

  locationQueryFailed = (error) =>
    console.log("Error on fetch bus stops by location")
    onFailureCallback("(Bus stop search failed)")
    return

  # start acquiring location
  navigator.geolocation.getCurrentPosition(locationQuerySucceeded, locationQueryFailed)
  return

### Show bus stop list in UI, actionType determines what happens after the busstop is selected ###
showBusStops = (busStops, err, actionType, kutsuplusDepartureStop) ->
  $list = $(busStopsPageId + ' ul')
  $list.empty()
  if err?
    $list.append('<li>' + err +  '</li>')
  else
    if busStops?
      for i, busStop of busStops
        if actionType == "kutsuplus" or actionType == "kutsuplusSend"
            refId = "#"
        else:
            refId = busStopInfoPageId
        $list.append("<li data-id='" + busStop.id + "'><a href='" + refId + "'>" + busStop.name + " (" + busStop.code + ")</a></li>")
    else
      $list.append('<li>(No nearby bus stops found)</li>')

  $list.listview("refresh")

  $list.on('click', 'li', () ->
    clickedBusStopId = $(this).attr('data-id')
    if clickedBusStopId?
      if actionType == "kutsuplus"
        destination_address = prompt("Please type your destination address")
        getCoordinatesFromAddress(destination_address, (latitude, longitude) ->
              fetchNearestBusStopsByCoordinates(latitude, longitude, (busStops) ->
                  # provide list of bus stops in UI
                  console.log("Getting nearest bus stops for Kutsuplus")
                  if busStops.length > 0
                    showBusStops(busStops, null, "kutsuplusSend", busStop.code)
                  else
                    showBusStops(null, null, "kutsuplusSend", busStop.code)
                  return      
              )
        )
      else if actionType == "kutsuplusSend"
        sendKutsuplusMessage(kutsuplusDepartureStop, busStop.code)
      else:
        busStopToShowId = clickedBusStopId
    else
      busStopToShowId = ''
  )

  return

millisecondsToTimeString = (milliseconds) ->
  x = parseInt(milliseconds)
  x = Math.floor(x / 1000)
  seconds = x % 60
  x = Math.floor(x / 60)
  minutes = x % 60
  x = Math.floor(x/ 60)
  hours = x % 24
  x = Math.floor(x / 24)
  days = x

  str = "#{seconds}s"
  if (minutes > 0)
    str = "#{minutes}m " + str
  if (hours > 0)
    str = "#{hours}h " + str
  if (days > 0)
    str = "#{days}d " + str

  return str

### Show Bus stop information in UI ###
showBusStop = (busInfoList, err) ->
  $list = $(busStopInfoPageId + ' ul')
  $list.empty()
  if err?
    $list.append('<li>' + err +  '</li>')
  else
    if busInfoList?

      for i, busInfo of busInfoList
        console.log("BUSINFO: " + JSON.stringify(busInfo))
        data = busInfo["line"] + ': '
        busEnterTime = new Date(parseInt(busInfo["timeStamp"])*1000) # unix epoch to epoch
        console.log("Line: " + busInfo["line"] + ": " + busEnterTime)
        currentTime = Date.now()
        difference =  busEnterTime.getTime() - currentTime

        if (difference < 0)
          data += '-'
        data += millisecondsToTimeString(Math.abs(difference))

        if busInfo["estimation"]
          data += ' (e)'
        $list.append('<li style="background-color: white;">' + data + '</li>')
    else
      $list.append('<li style="background-color: white;">(no buses approaching)</li>')

  $list.listview("refresh")
  return

# Event happens when the user has selected a bus stop to show.
$(busStopInfoPageId).bind 'pageinit', (e, data) ->
  console.log("busStopInfoPageId: pageinit")
  $list = $(busStopsPageId + ' ul')
  $list.empty()
  $list.listview()
  return

$(busStopInfoPageId).bind 'pageshow', (e, data) ->
  console.log("busStopInfoPageId: pageshow")
  
  id = busStopToShowId

  if (id? && id != '')
    console.log("bus stop id: " + id)
    $list = $(busStopsPageId + ' ul')
    $list.empty()

    onBusStopClicked = (busStopId) ->
      fetchTimeEstimationsForBusStop(busStopId, (busInfoList) ->
        # onSuccess
        if busInfoList.length > 0
          console.log(busInfoList.length + " buses approaching")
          showBusStop(busInfoList, null)
        else
          showBusStop(null, null)
        return
      , (error) ->
        # onError
        showBusStop(null, error)
        return
      )
      return

    onBusStopClicked(id)
  return

# Kutsuplus page
$(kutsuplusPageId).bind 'pageshow', (e, data) ->
  $list = $(kutsuplusPageId + ' ul')
  $list.empty()
  # Show nearby bus stops
  console.log("bus stop page shown")
  fetchNearestBusStops((busStops) ->
      # provide list of bus stops in UI
      if busStops.length > 0
        showBusStops(busStops, null, "kutsuplus")
      else
        showBusStops(null, null, "kutsuplus")
      return
  , (errorMessage) ->
    # onFailedCallback
    console.log(errorMessage)
    showBusStops(null, errorMessage, "kutsuplus")
    return
  )
  return

# Event happens when the user has selected the "bus stops nearby" link from the front page.
# pageinit event happens before the pageshow event
$(busStopsPageId).bind 'pageshow', (e, data) ->
  $list = $(busStopsPageId + ' ul')
  $list.empty()
  # Show nearby bus stops
  console.log("bus stop page shown")
  fetchNearestBusStops((busStops) ->
      # provide list of bus stops in UI
      if busStops.length > 0
        showBusStops(busStops, null, actionType)
      else
        showBusStops(null, null, actionType)
      return
  , (errorMessage) ->
    # onFailedCallback
    console.log(errorMessage)
    showBusStops(null, errorMessage, actionType)
    return
  )
  return


