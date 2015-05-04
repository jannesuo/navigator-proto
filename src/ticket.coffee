$(document).on "deviceready", ->
  console.log("Laite valmis")
  $('#ticket-button').on "click", ->
    confirmation = confirm("Do you want to buy a Helsinki internal SMS ticket? This costs 2 euros and is valid in Helsinki trains and trams.")
    messageInfo =
      phoneNumber: "+358440301091",
      textMessage: "Ostan lipun"
    
    if confirmation
        sms.sendMessage(messageInfo,
          (message) ->
            console.log("SMS ticket purchased succesfully: " + message)
            alert("SMS ticket is ordered successfully. You should receive the ticket in a while.")
          (error) ->
            console.log("code: " + error.code + ", message: " + error.message)
        )
    else
        console.log("SMS ticket purchase cancelled.")
