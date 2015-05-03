
# Configurations
busStopsMaximumCountForResults = 5
busStopSearchDiameter = 1000
busStopInfoRefreshInterval = 5000 # how often bus stop info is refreshed, milliseconds
busStopMaximumVisibleBusDelay = 21600000 # hide buses that are more than 6h away (6h = 21600000 ms)
busStopsPageId = "#bus-stop-page"
busStopInfoPageId = "#bus-stop-info"
busStopInfoPageHeaderId = "#bus-stop-info-header"
fetchBusStopsUrl = "http://www.pubtrans.it/hsl/stops"
fetchBusStopDataUrl = "http://www.pubtrans.it/hsl/reittiopas/departure-api"

# Global variables
busStopToShowId = ''
busStopDataRefreshIntervalId = ''
busStopDataRefreshOngoing = false
busStopInfoPageVisible = false


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
        console.log("parsing bus stop data...")
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

        loading('hide')
        console.log("done...")
        onSuccessCallback(busInfos)
      else
        empty = []
        loading('hide')
        onSuccessCallback(empty)
      return

    busStopOnError = (error) ->
      console.log("Error on fetch estimations for a bus stop: " + error)
      loading('hide')
      onFailureCallback("(Bus stop search failed)")
      return

    url = fetchBusStopDataUrl + "?stops%5B%5D=#{busStopId}"
    console.log("API call: " + url)
    loading('show')
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
  loading('show')
  locationQuerySucceeded = (position) ->
    loading('hide')
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
    loading('hide')
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
        $list.append("<li data-id='" + busStop.id + "'><a href='" + busStopInfoPageId + "'><img class='ui-li-icon' src='static/images/bus_stop_symbol.png' alt='(stop)' />" + busStop.name + " (" + busStop.code + ")</a></li>")
    else
      $list.append('<li>(No nearby bus stops found)</li>')

  $list.listview("refresh")

  $list.on('click', 'li', () ->
    clickedBusStopId = $(this).attr('data-id')
    if clickedBusStopId?
      $(busStopInfoPageHeaderId).text($(this).text())
      busStopToShowId = clickedBusStopId
    else
      $(busStopInfoPageHeaderId).text("(none selected)")
      busStopToShowId = ''
  )

  return

millisecondsToTimeString = (milliseconds) ->
  x = parseInt(milliseconds)
  if x == 0
    return "now"

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
  if !busStopInfoPageVisible
    console.log("no bus stop page visible when asked to show bus stops")
    return # user has navigate away from this page

  defaultNoItemsRow = '<li style="background-color: black; color: white;">(no buses approaching)</li>'
  $list = $(busStopInfoPageId + ' ul')
  $list.empty()
  if err?
    console.log("ERR: " + err)
    $list.append('<li>' + err +  '</li>')
  else
    if busInfoList?
      count = 0
      for i, busInfo of busInfoList
        console.log("BusInfo" + i + ": " + busInfo)
        data = busInfo["line"] + ': '
        busEnterTime = new Date(parseInt(busInfo["timeStamp"])*1000) # unix epoch to epoch
        currentTime = Date.now()
        difference =  busEnterTime.getTime() - currentTime
        if (difference < 0)
          difference = 0 # Show all buses that has past their expected time as 0 minutes
        else if (difference > busStopMaximumVisibleBusDelay)
          console.log("BusInfo" + i + ": filtered based on time offset")
          continue # filter this info
        data += millisecondsToTimeString(Math.abs(difference))

        if not busInfo["estimation"]
          data += ' (real time)'

        $list.append('<li style="background-color: white;"><img class="ui-li-icon" src="static/images/bus.png" alt="(bus)" />' + data + '</li>')
        count += 1

      if count == 0
        $list.append(defaultNoItemsRow)
    else
      $list.append(defaultNoItemsRow)

  $list.listview("refresh")
  return

# Event happens when the user has selected a bus stop to show.
$(busStopInfoPageId).bind 'pageinit', (e, data) ->
  console.log("busStopInfoPageId: pageinit")
  $list = $(busStopInfoPageId + ' ul')
  $list.empty()
  $list.listview()
  return

$(busStopInfoPageId).bind 'pageshow', (e, data) ->
  console.log("busStopInfoPageId: pageshow")
  busStopInfoPageVisible = true

  # Clear list from existing info
  $list = $(busStopInfoPageId + ' ul')
  $list.empty()

  # fetch data & start periodic refreshing task
  refreshBusStopInfo()
  startBusStopRefreshing()
  return

$(busStopInfoPageId).bind 'pagebeforehide', (e, data) ->
  console.log("busStopInfoPageId: pagebeforehide")
  busStopInfoPageVisible = false
  stopBusStopRefreshing() # cancel periodic refreshing task

# Event happens when the user has selected the "bus stops nearby" link from the front page.
# pageinit event happens before the pageshow event
$(busStopsPageId).bind 'pageshow', (e, data) ->
  $list = $(busStopsPageId + ' ul')

  # Show nearby bus stops
  console.log("bus stop page shown")
  fetchNearestBusStops((busStops) ->
    # onSuccessCallback
    $list.empty()
    # provide list of bus stops in UI
    if busStops.length > 0
      showBusStops(busStops, null)
    else
      showBusStops(null, null)

    return
  , (errorMessage) ->
    # onFailedCallback
    $list.empty()
    console.log(errorMessage)
    showBusStops(null, errorMessage)
    return
  )

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

###
   Fill bus estimations list for single bus stop
###
refreshBusStopInfo = () ->
  if busStopDataRefreshOngoing || !busStopInfoPageVisible
    return # allow only single execution at a time while page is visible

  console.log("periodic bus stop info refresh...")
  busStopDataRefreshOngoing = true # prevent new refreshes while current refresh is ongoing
  id = busStopToShowId
  if (id? && id != '')
    console.log("bus stop id: " + id)
    onBusStopClicked = (busStopId) ->
      fetchTimeEstimationsForBusStop(busStopId, (busInfoList) ->
# onSuccess
        if busInfoList.length > 0
          console.log(busInfoList.length + " buses approaching")
          showBusStop(busInfoList, null)
        else
          showBusStop(null, null)
        busStopDataRefreshOngoing = false
        return
      , (error) ->
# onError
        showBusStop(null, error)
        busStopDataRefreshOngoing = false
        return
      )
      return
    if !busStopInfoPageVisible
      busStopDataRefreshOngoing = false
      return # user has navigated away from this page
    onBusStopClicked(id)
  return


###
  Helper function to show or hide ajax loading animation
  call loading('show') or loading('hide') to change the loading status
###
loading = (showOrHide) ->
  setTimeout(() ->
    $.mobile.loading(showOrHide);
  , 1)


###
  Start task that is refreshing bus estimations periodically
###
startBusStopRefreshing = () ->
  stopBusStopRefreshing() # clear any existing interval refresh tasks
  busStopDataRefreshIntervalId = setInterval( () ->
    refreshBusStopInfo()
  , busStopInfoRefreshInterval
  )


###
  Stop task that is refreshing bus estimations periodically
###
stopBusStopRefreshing = () ->
  if (busStopDataRefreshIntervalId? && busStopDataRefreshIntervalId != '')
    clearInterval(busStopDataRefreshIntervalId)
    busStopDataRefreshIntervalId = ''