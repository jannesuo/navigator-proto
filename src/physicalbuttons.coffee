# Handles physical buttons behaviour
$(document).on 'deviceready', ->
  # It opens the popup-menu of each page
  $(document).on 'menubutton', ->
    $.mobile.activePage.find('.physical-menu-btn').trigger 'click'
  # Add here other button listeners
