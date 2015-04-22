
# Configurations
busStopsMaximumCountForResults = 5
busStopSearchDiameter = 100
busStopsPageId = "#bus-stop-page"
busStopInfoPageId = "#bus-stop-info"
fetchBusStopsUrl = "http://www.pubtrans.it/hsl/stops"
fetchBusStopDataUrl = "http://www.pubtrans.it/hsl/reittiopas/departure-api"

onBusStopClicked = (busStopId) ->
  fetchTimeEstimationsForBusStop(busStopId, (busInfoList) ->
    # onSuccess
    if busInfoList.length > 0
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
        for bus of busStopData
          busInfo = {}

          busInfo["line"] = bus.line
          businfo["estimation"] = true
          if bus.rtime?
            businfo["timeStamp"] = new Date(bus.rtime)
            businfo["estimation"] = false
          else
            businfo["timeStamp"] = new Date(bus.time)

          busInfos.add(busInfo)

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

### Show bus stop list in UI ###
showBusStops = (busStops, err) ->
  $list = $(busStopsPageId + ' ul')
  $list.empty()
  if err?
    $list.append('<li>' + err +  '</li>')
  else
    if busStops?
      for i, busStop of busStops
        console.log("BUSSTOP: " + JSON.stringify(busStop))
        func = 'onBusStopClicked("' + busStop.id + '")'
        $list.append("<li><a href='#' onClick='" + func + "'>" + busStop.name + " (" + busStop.code + ")</a></li>")
    else
      $list.append('<li>(No nearby bus stops found)</li>')

  $list.listview("refresh")
  return

### Show Bus stop information in UI ###
showBusStop = (busInfoList, err) ->
  $list = $(busStopInfoPageId + ' ul')
  $list.empty()
  if err?
    $list.append('<li>' + err +  '</li>')
  else
    if busInfoList?
      for busInfo of busInfoList
        data = busInfo["timeStamp"]
        if busInfo["estimation"]
          data += ' (e)'
        $list.append('<li>' + data + '</li>')
    else
      $list.append('<li>(no buses approaching)</li>')

  $list.listview("refresh")
  return

# Event happens when the user has selected a bus stop to show.
$(busStopInfoPageId).bind 'pageinit', (e, data) ->
  $list = $(busStopsPageId + ' ul')
  $list.empty()
  $list.listview()
  return

$(busStopInfoPageId).bind 'pageshow', (e, data) ->
  $list = $(busStopsPageId + ' ul')
  $list.empty()
  $list.listview()
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
        showBusStops(busStops, null)
      else
        showBusStops(null, null)
      return
  , (errorMessage) ->
    # onFailedCallback
    console.log(errorMessage)
    showBusStops(null, errorMessage)
    return
  )
  return

$('#kutsuplus-button').on "click", ->

    failureFunction = (error) -> 
        console.log("nearest Bus stop search failed. Error message: "+error)
    console.log("Starting Kutsuplus functionality")
    fetchNearestBusStops(showBusStops, failureFunction)



    messageInfo =
      phoneNumber: "+358440301091",
      textMessage: "Ostan lipun"
    confirmation = confirm("Do you want to order a Kutsuplus car? This costs up to 20 euros")
    if confirmation
        sms.sendMessage(messageInfo,
          (message) ->
            console.log("Kutsuplus ordered succesfully: " + message)
          (error) ->
            console.log("code: " + error.code + ", message: " + error.message)
        )
    else
        console.log("SMS ticket purchase cancelled.")
