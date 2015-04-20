$(document).on "deviceready", ->
  $('#mac-address').on "click", ->
    console.log("Looking for mac addresses...")
    getNearbyMacAddresses()
    
nearbyAddresses = []
getNearbyMacAddresses = () ->
    nearbyAddresses = navigator.wifi.getAccessPoints(onSuccess, onFailure) 
    console.log("Nearby MAC addresses: "+nearbyAddresses)
    return nearbyAddresses
  
onSuccess = (listOfAccessPoints) -> 
    nearbyAddresses = (accessPoint.BSSID for accessPoint in listOfAccessPoints)
    return nearbyAddresses

onFailure = () -> 
    console.log("An error occured with finding the nearest Mac address")