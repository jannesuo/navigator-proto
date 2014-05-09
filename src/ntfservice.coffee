# functions for communicating with backgroud notification service 
# which is deployed by cordova plugin add https://github.com/linzhiqi/bgs-core.git 
# the java code is already customized for this project

window.ntf_srv_startService = () ->
    window.ntf_srv.startService( onSuccess = ((r)->),(e) -> 
        alert('An error has occurred in startService.'+JSON.stringify(e))
    )

window.ntf_srv_setItinerary = (itinerary) ->
    config =
        "itinerary": itinerary
    window.ntf_srv.setConfiguration(config,onSuccess = (r)->
        ntf_srv_enableTimer()
    ,(e) ->
        alert('An error has occurred in setConfig.'+JSON.stringify(e))
    )

window.ntf_srv_stopNtfService = () ->
    ntf_srv.disableTimer( onSuccess = (r)->
        ntf_srv_stopService()
    ,((e) ->))

ntf_srv_enableTimer = () ->
    window.ntf_srv.enableTimer( 10000,onSuccess = ((r)->),(e) -> 
        alert('An error has occurred in enableTimer.'+JSON.stringify(e))
    )

ntf_srv_stopService = () ->
    window.ntf_srv.stopService( onSuccess = ((r)->),(e) -> 
        alert('An error has occurred in startService.'+JSON.stringify(e))
    )

document.addEventListener('deviceready', () ->
    window.ntf_srv=cordova.require('com.red_folder.phonegap.plugin.backgroundservice.BackgroundService')
, true);
