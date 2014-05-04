# functions for communicating with backgroud notification service 
# which is deployed by cordova plugin add https://github.com/phpsa/cbsp.git
# src/android/MyService.java in the plugin packege needs to be edited into your own customized service

window.ntf_srv_getStatus = () ->
    window.ntf_srv.getStatus( ((r) ->), (e) -> 
        alert('An error has occurred in getStatus.'+JSON.stringify(e))
    )

window.ntf_srv_startService = () ->
    window.ntf_srv.startService( onSuccess = ((r)->),(e) -> 
        alert('An error has occurred in startService.'+JSON.stringify(e))
    )
    #window.ntf_srv_enableTimer()

window.ntf_srv_enableTimer = () ->
    window.ntf_srv.enableTimer( 10000,onSuccess = ((r)->),(e) -> 
        alert('An error has occurred in enableTimer.'+JSON.stringify(e))
    )

window.ntf_srv_setConfig = (itinerary) ->
    config =
        "itinerary": itinerary
    window.ntf_srv.setConfiguration(config,onSuccess = ((r)->),(e) ->
        alert('An error has occurred in setConfig.'+JSON.stringify(e))
    )



document.addEventListener('deviceready', () ->
    window.ntf_srv=cordova.require('com.red_folder.phonegap.plugin.backgroundservice.BackgroundService')
    #window.ntf_srv_getStatus()
    window.ntf_srv_startService()
, true);
