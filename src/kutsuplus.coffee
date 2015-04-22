$(document).on "deviceready", ->
  console.log("Laite valmis")
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
            console.log("SMS ticket purchased succesfully: " + message)
          (error) ->
            console.log("code: " + error.code + ", message: " + error.message)
        )
    else
        console.log("SMS ticket purchase cancelled.")