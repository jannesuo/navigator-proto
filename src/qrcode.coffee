startScan = ->
  cordova.plugins.barcodeScanner.scan(
    (result) ->
      if not result.cancelled
        $ '#input-search input'
          .val result.text
          .trigger "keyup"
    (error) ->
      alert "Scanning failed: #{error}"
  )

$(document).on "deviceready", ->
  $('#qr-button').on "click", startScan