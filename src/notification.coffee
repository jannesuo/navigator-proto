$(document).on "deviceready", ->
    setTimeout(()->
            pushNotification = window.plugins.pushNotification
            pushNotification.register emptyFunction, emptyFunction, #registering device/requesting existing id
                                                {
                                                    "senderID": "839795242412",
                                                    "ecb": "startWaitingMessages",
                                                }
        , 4)
    pushNotification = window.plugins.pushNotification
    # pushNotification.register emptyFunction, emptyFunction, #registering device/requesting existing id
    #                                             {
    #                                                 "senderID": "839795242412",
    #                                                 "ecb": "startWaitingMessages",
    #                                             }
    $("#watch-disruptions").on "click", -> # clickListener "Watch disruptions" button
    	pushNotification.register successHandler, errorHandler, #registering device/requesting existing id
                                                    {
                                                        "senderID": "839795242412",
                                                        "ecb": "onNotification",
                                                    }
    $("#stop-watch-disruptions").on "click", -> # clickListener "Stop watching" button
    	pushNotification.register successHandler, errorHandler, #registering device/requesting existing id
                                                    {
                                                        "senderID": "839795242412",
                                                        "ecb": "stopWatchDisruptions",
                                                    }
    $("#test-message-sender").on "click", -> # send test message
        route_details = {
            "msg": "test",
            "category": "espooInternal",
            } 
        $.post("https://aalto-hsl-2015-3.herokuapp.com/send-test-message", route_details).done (data) ->
                alert "You sent test message"


    successHandler = (result) -> # plugin's success handler
        alert "Request sent"
    errorHandler = (error) ->   # plugin's error handler
        alert "Error occured: #{error}"
    emptyFunction = (result) ->
        return

onNotification = (e) -> # triggered when notification from GCM arrived after pressing "Watch disruptions" button
    switch e.event
        when "registered" # device registered
            temp_itinerary = citynavi.get_itinerary() # get current itinerary

            # create JSON route_details for sending to server https://aalto-hsl-2015-3.herokuapp.com
            route_details = {registration_id: "#{e.regid}",sections: []} 
            categories = {"1": "helsinkiInternal", "2":"espooInternal", "3":"train", "4":"vantaaInternal", "5":"regional", "7":"Uline",}
            for leg in temp_itinerary["legs"]
                if leg["mode"] != "WAIT" and leg["mode"] != "WALK"
                    if leg["mode"] == "TRAM"
                        category = "tram"
                    else if leg["mode"] == "FERRY"
                        category = "ferry"
                    else
                        categoryNumber = parseInt leg["routeId"].charAt(0)
                        if categoryNumber of categories 
                            category = categories[categoryNumber]
                        else
                            category = "none"
                    start = new Date(leg["startTime"])
                    end = new Date(leg["endTime"])
                    route = {
                        startTime: start.toISOString(),
                        endTime: end.toISOString(),
                        line: leg["route"],
                        category: category
                    }
                    route_details["sections"].push route
            $.post("https://aalto-hsl-2015-3.herokuapp.com/registerclient", route_details).done (data) ->
                alert "You are watching disruptions for selected routes" # notify about successful subscription for disruptions notifications       
        when "message" # needs to be modified. First testing required
            alert "You received new disruption message"
            if e.foreground
                showDisruptions(e.payload)
            else
                showDisruptions(e.payload)
        when "error"
            alert e.msg
        else 
            alert "unknown event"

stopWatchDisruptions = (e) -> # triggered when notification from GCM arrived after pressing "Stop watching" button
    switch e.event
        when "registered"
            $.post "https://aalto-hsl-2015-3.herokuapp.com/deregisterclient", {registration_id:"#{e.regid}"}
              .done (data) ->
                  alert "You stopped watching for disruptions"

startWaitingMessages = (e) ->
    switch e.event
        when "registered"
            break
        when "message" # needs to be modified. First testing required
            alert "You received new disruption message"
            if e.foreground
                showDisruptions(e.payload)
            else
                showDisruptions(e.payload)
        when "error"
            alert e.msg
        else 
            alert "unknown event"


showDisruptions = (info) ->
    $list = $("#disruptions ul")
    result = ""
    if $("#disruptions").css("display") != "block"
        $list.empty()
        if info?
          for i, message of info
            result += message + "<br>"
          $list.append("<li style='background-color:black; color:white; font-weight:normal;'>"+result+"</li>")
        else
          $list.append("<li style='background-color:black; color:white; font-weight:normal;'>(No disruptions)</li>")

        $("#show-disruptions-trigger").trigger("click")
    else     
        if info?
          for i, message of info
            result += message + "<br>"
          $list.append("<li style='background-color:black; color:white; font-weight:normal;'>"+result+"</li>")
          $list.listview("refresh")
    return