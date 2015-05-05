#Fades toast-notification messages. Source: https://gist.github.com/kamranzafar/3136584
toast = (msg) ->
  $('<div class=\'ui-loader ui-overlay-shadow ui-body-e ui-corner-all\'><h3>' + msg + '</h3></div>').css(
    display: 'block'
    opacity: 0.90
    position: 'fixed'
    padding: '7px'
    'text-align': 'center'
    width: '270px'
    left: ($(window).width() - 284) / 2
    top: $(window).height() / 2).appendTo($.mobile.pageContainer).delay(4000).fadeOut 400, ->
    $(this).remove()
    return
  return

$(document).on "deviceready", ->
  console.log("Laite valmis")
  $('#ticket-button').on "click", ->
    confirmation = confirm("Do you want to buy a Helsinki internal SMS ticket? This costs 2 euros and is valid in Helsinki trains and trams.")
    messageInfo =
      phoneNumber: citynavi.config.ticket_sms_number
      textMessage: citynavi.config.ticket_sms_message
    
    if confirmation
        sms.sendMessage(messageInfo,
          (message) ->
            console.log("SMS ticket purchased succesfully: " + message)
            toast("SMS ticket is ordered successfully. You should receive the ticket in a while.")
          (error) ->
            console.log("code: " + error.code + ", message: " + error.message)
        )
    else
        console.log("SMS ticket purchase cancelled.")
