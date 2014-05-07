# original files are from https://github.com/kolwit/com.kolwit.pickcontact
# forked to https://github.com/aiksiang/com.kolwit.pickcontact

# This allows the success function to retrieve the list of contacts
chosenContact = {}

addContactAddress = ->
	window.plugins.PickContact.chooseContact (contactInfo) ->
		chosenContact = contactInfo
		# Find the particular contact from the address book in device
		options = new ContactFindOptions()
		q = contactInfo.displayName
		options.filter = q
		options.multiple = true
		fields = ["displayName", "name", "addresses"]
		navigator.contacts.find fields, onSuccessContactChooser, onErrorContactChooser, options

onSuccessContactChooser = (contacts)->
	for names in contacts
		# Make sure that people with the same name is not called instead of the intended one
		# Future implementation: Should do the search for Id instead of those fields listed
		if names.id == chosenContact.contactId
			# If contact has no address
			if !names.addresses?
				address = new ContactAddress()
				# Take the data from the selected address
				curLoc = $('#input-search input').data 'selected_location'
				if curLoc isnt ""
					address.formatted = curLoc
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