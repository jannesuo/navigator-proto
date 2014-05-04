#Find an address scanning a QR-Code using cam
#then it is pushed in the search field and autocopletion is invoked throught the event "keyup"
$(document).on "deviceready", ->
  $('#qr-button').on "click", ->
    cordova.plugins.barcodeScanner.scan(
      (result) ->
        if not result.cancelled
          $ '#input-search input'
            .val result.text
            .trigger "keyup"
      (error) ->
        alert "Scanning failed: #{error}"
    )
  
