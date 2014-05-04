# https://github.com/kolwit/com.kolwit.pickcontact
# forked to https://github.com/aiksiang/com.kolwit.pickcontact

chosenContact = {}

addContactAddress = ->
	window.plugins.PickContact.chooseContact (contactInfo) ->
		chosenContact = contactInfo
		options = new ContactFindOptions()
		q = contactInfo.displayName
		options.filter = q
		options.multiple = true
		fields = ["displayName", "name", "addresses"]
		navigator.contacts.find fields, onSuccessContactChooser, onErrorContactChooser, options

onSuccessContactChooser = (contacts)->
	for names in contacts
		if names.id == chosenContact.contactId
			if !names.addresses?
				address = new ContactAddress()
				textField = $('#input-search input').val()
				if textField != ""
					address.formatted = textField
					names.addresses = []
					names.addresses.push address
					names.save()
					alert "Address Saved"
			else
				alert "Contact Already Has Address"
onErrorContactChooser = (contactError) ->
    console.log "Error Finding Contact"

$(document).on "deviceready", ->
  $('#addContactAddress').on "click", addContactAddress