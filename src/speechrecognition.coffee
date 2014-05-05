# Find an address pronuncing it.
$(document).on "deviceready", ->
  $('#speech-button').on "click", ->
    window.plugins.speechrecognizer.startRecognize(
      (results) ->
        $ '#input-search input'
          .val results[0]
          .trigger "keyup"
      (errorMessage) ->
        alert "Error: recognition failed!\nPlease retry."
      1 # Max matches
      "Pronounce the address" # Prompt string
      citynavi.config.speech_language
    )
