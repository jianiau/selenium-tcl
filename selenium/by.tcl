namespace eval ::selenium {

	# Set of supported locator strategies.
    variable By 
    
    array set By {
		-id					"id"
		-xpath				"xpath"
		-link_text			"link text"
		-partial_link_text	"partial link text"
		-name				"name"
		-tag_name 			"tag name"
		-class  			"class name"
		-css		"css selector"
	}

}
