package require selenium::utils::port
package require selenium::utils::json

package require selenium::utils::base64

namespace eval ::selenium {

	namespace export WebDriver
    
    set JAVASCRIPT_RETURNS_ELEMENT 0
    set JAVASCRIPT_RETURNS_ELEMENTS 1
	
	oo::class create WebDriver {
		
		# Controls a browser by sending commands to a remote server.
		# This server is expected to be running the WebDriver wire protocol as define
		# here: http://code.google.com/p/selenium/wiki/JsonWireProtocol

		# :Attributes:
		# - remote_connection - The CommandExecutor object used to execute commands.
		# - error_handler - errorhandler.ErrorHandler object used to verify that the server did not return an error.
		# - session_ID - The session ID to send with every $Command::
		# - capabilities - A dictionary of capabilities of the underlying browser for this instance's session.
        
        mixin ::selenium::Mixin_For_Element_Retrieval ::selenium::Mixin_For_Scrolling ::selenium::Mixin_For_Mouse_Interaction
		variable driver remote_connection error_handler current_capabilities session_ID Command Mouse_Button Exception StatusCache By w3c_compliant JAVASCRIPT_RETURNS_ELEMENT JAVASCRIPT_RETURNS_ELEMENTS
		

		constructor {service_url desired_capabilities {required_capabilities {}}} {
			# Create a new driver that will issue commands using the wire protocol.
			#
			# :Args:
			# - service_url - The URL where the service is provided
			# - desired_capabilities - Dictionary holding predefined values for starting a browser
            # - required_capabilities (Optional) - A dictionary of required capabilities of the underlying browser for this instance's session.            	
            set driver [self]
            
            namespace import ::selenium::utils::json::compile_to_json \
                                ::selenium::webelement::WebElement \
                                ::selenium::container_of_webelements::Container_Of_WebElements

            namespace eval [self] {
                namespace upvar ::selenium Command Command Exception Exception Mouse_Button Mouse_Button StatusCache StatusCache By By
            }
			set remote_connection [::selenium::Remote_Connection new $service_url]

			set session_ID ""
			set current_capabilities [dict create]
			
			set error_handler [::selenium::ErrorHandler new]

			my start_client
			my start_session $desired_capabilities $required_capabilities
		}
        
        forward wait_until_connectable ::selenium::utils::port::wait_until_connectable
        forward wait_until_not_connectable ::selenium::utils::port::wait_until_not_connectable

        method session_ID {} {

            return $session_ID
        }
		
		method name {} {
			# Returns the name of the underlying browser for this instance.
			# 
			# :Usage:
			# 	$driver name

			if {[dict exists $current_capabilities browserName]} {
				return [dict get $current_capabilities browserName]
			} else {
				throw $Exception(WebdriverException) {browserName not specified in session capabilities}
			}
		}
		
		method start_client {} {
			# Called before starting a new session. This method may be overridden to define custom startup behavior.

		}

		method stop_client {} {
			# Called after executing a quit command. This method may be overridden to define custom shutdown behavior.

		}
        
		method start_session {desired_capabilities required_capabilities} {
			# Creates a new session with the desired capabilities.
			# 
			# :Args:
			# - browser_name - The name of the browser to request.
			# - version - Which browser version to request.
			# - platform - Which platform to request the browser on.
			# - javascript_enabled - Whether the new session should support JavaScript.
			# - browser_profile - A selenium.driver.firefox.firefox_profile.FirefoxProfile object. Only used if Firefox is requested.

            if {$required_capabilities eq ""} {
                set json_response [my execute $Command(NEW_SESSION) desiredCapabilities $desired_capabilities]
            } else {
                set json_response [my execute $Command(NEW_SESSION) desiredCapabilities $desired_capabilities requiredCapabilities $required_capabilities]
            }
	    
	    #  Test if it's new JSON whichis wrapped in brace called "value" and extract if so.
            if {![dict exists $json_response sessionId]} {
                set json_response [dict get $json_response value]
            }
	    
            set session_ID [dict get $json_response sessionId]
            set current_capabilities [dict get $json_response capabilities]

            # Quick check to see if we have a W3C Compliant browser.
            # According to SauceLabs "If that line begins with 'desiredCapabilities', you are running the non-W3C version. If it begins with 'capabilities', you are running the new W3C-compliant version."
            # Refactor to proper test https://wiki.saucelabs.com/display/DOCS/Selenium+W3C+Capabilities+Support
            if {[dict exists $json_response value desiredCapabilities]} {
                set w3c_compliant 0
            } else {
                set w3c_compliant 1
            }
		}

		method execute {command_name args} {
			# Sends a command to be executed by a command executor.
			# 
			# :Args:
			# - command_name: The name of the command to execute as a string.
			# - parameters_var: Variable name containing a dict object of named parameters to send with the $Command::
			# 
			# :Returns:
			# 	The command's JSON response loaded into a dict object.

			set response [$remote_connection dispatch $session_ID $command_name $args]

			set json_response [$error_handler check_response $session_ID $command_name $args $response]
            return $json_response
		}
		
		method execute_and_get_value {command_name args} {
			if {[llength $args] != 0} {
				set json_response [my execute $command_name {*}$args]
			} else {
				set json_response [my execute $command_name]
			}
			
			return [dict get $json_response value]
		}
		
		method get {url} {
			# Loads a web page in the current browser session.
		
			my execute $Command(GET) url $url
		}
		
		method title {} {
			# Returns the title of the current page.
			#
			# :Usage:
			#	driver title
			
			return [my execute_and_get_value $Command(GET_TITLE)]
		}
        
        method execute_javascript {script args} {
			# Executes JavaScript in the current window/frame synchronously or asynchronously.
			# 
			# :Args:
			# - script: The JavaScript to execute.
            #
            # :Options:
			# -arguments spec1? arg1? spec2? arg2?...: Pairs of json specifications and tcl values as arguments for your JavaScript.
            # -async: Execute javascript asyncronously
            # -command_var: Variable to store the new command for the element/s
			# -returns_element: Flag indicating that the script returns an element
            # -returns_elements: Flag indicating that the script returns a list of elements
            #
			# :Usage:
			# 	driver execute_javascript {return document.title}

            set script_arguments [list]
            set async 0
            set level 1
       
            set i 0
            
            set options_len [llength $args]

            while {$i < $options_len} {
                
                set optionName [lindex $args $i]
                
                switch $optionName {
                    -arguments {
                        incr i
                        
                        if {$i == $options_len } {
                            return -code error "No value for -arguments"
                        }
                        
                        foreach {argument_type argument_value} [lindex $args $i] {
                            lappend script_arguments [my _convert_to_script_argument $argument_type $argument_value]
                        }                        
                    }
                    -argument {
                        incr i
                        
                        if {$i == $options_len} {
                            return -code error "No value for argument type"
                        }
                        set argument_type [lindex $args $i]

                        incr i
                        
                        if {$i == $options_len} {
                            return -code error "No value for argument name"
                        }

                        set argument_value [lindex $args $i]
                        
                        lappend script_arguments [my _convert_to_script_argument $argument_type $argument_value]
                    }
                    -async {
                        set async 1
                    }
                    -returns_element {
                        set return_value $JAVASCRIPT_RETURNS_ELEMENT
                    }
                    -returns_elements {
                        set return_value $JAVASCRIPT_RETURNS_ELEMENTS
                    }
                    -command_var {
                        incr i
                        if {$i == $options_len} {
                            return -code error "No value for -commnad_var"
                        }

                        set command_var [lindex $args $i]
                    }
                    -level {
                        incr i
                        
                        if {$i == $options_len} {
                            return -code error "No value for -level"
                        }
                        set level [lindex $args $i]
                    }
                }
                
                incr i
            }
                        
            if {[info exists command_var] && ![info exists return_value]} {
                return -code error "option -command_var is only allowed when we expect element/s"
            }
            
            if {$async} {
                set selenium_command $Command(EXECUTE_ASYNC_SCRIPT)
                
            } else {
                set selenium_command $Command(EXECUTE_SCRIPT)
            }
            
            set value [my execute_and_get_value $selenium_command script $script args $script_arguments]
            
            if {[info exists return_value]} {
                if {$return_value == $JAVASCRIPT_RETURNS_ELEMENT} {
                    set selenium_ID [lindex $value 1]
                    if {[info exists command_var]} {
                        return [my create_webelement $selenium_ID $command_var [expr $level+1]]
                    } else {
                        return $selenium_ID
                    }
                } else {
                    set list_of_selenium_IDs [list]
                    foreach element $value {
                        set selenium_ID [lindex $element 1]
                        lappend list_of_selenium_IDs $selenium_ID
                    }
                    
                    if {[info exists command_var]} {
                        return [my create_container_of_webelements $list_of_selenium_IDs $command_var [expr $level+1]]
                    } else {
                        return $list_of_selenium_IDs
                    }                    
                }
            } else {
                return $value
            }
		}
        
        forward execute_script my execute_javascript
        
        method _convert_to_script_argument {argument_type argument_value} {
            switch -exact $argument_type {
                string -
                number -
                boolean -
                bool {
                    return [compile_to_json $argument_type $argument_value]
                }
                element {
                    return [compile_to_json dict [dict create ELEMENT $argument_value]]
                }
                default {
                    throw throw $Exception(WebDriver) "Invalid type: $argument_type"
                }
            }
        }
        
        method remove_webelement_from_DOM {webelement} {
            # It remove a webelement from DOM
			# 
			# :Args:
			# - webelement: The element ID of the webelement to remove
            
            my execute_javascript {
                var element = arguments[0];
                element.parentNode.removeChild(element);
            } -arguments [list element $webelement]
        }
        
        method get_base64_image {image_webelement} {
            return [my execute_javascript {
                    var HTMLImageElement = arguments[0]
                
                    var canvas = document.createElement("canvas");
                    canvas.width = HTMLImageElement.width;
                    canvas.height = HTMLImageElement.height;
                    var ctx = canvas.getContext("2d");
                    ctx.drawImage(img, 0, 0);
                    var dataURL = canvas.toDataURL("image/png");
                    return dataURL.replace(/^data:image\/(png|jpg);base64,/, "");
                } -arguments [list element $image_webelement]]
        }
        
        method active_webelement {{command_var ""} {level 1}} {
			# Returns the element with focus, or BODY if nothing has focus.
			# 
			# :Usage:
			# 	set element [driver active_element]
	
			set selenium_ID [lindex [$driver execute_and_get_value $Command(GET_ACTIVE_ELEMENT)] 1]
            return $selenium_ID
		}

        method create_webelement {selenium_ID {command_var ""} {level 1}} {
            # Creates a web element with the specified element_id.   
            if {$command_var ne ""} {
                upvar $level $command_var element
                set element [WebElement new $driver $selenium_ID]

                trace add variable element unset [list ::apply [list args [list $element destroy]]]
            } else {
                upvar $level $::selenium::PACKAGE_SIGNATURE signature
                
                set element [WebElement new $driver $selenium_ID]
                trace add variable signature unset [list ::apply [list args [list $element destroy]]]
            }   
            return $element
        }
        
        method create_container_of_webelements {list_of_selenium_IDs {command_var ""} {level 1}} { 

            if {$command_var ne ""} {
                upvar $level $command_var container
                
                set container [Container_Of_WebElements new $driver $list_of_selenium_IDs]
                trace add variable container unset [list ::apply [list args [list $container destroy]]]
            } else {
                upvar $level $::selenium::PACKAGE_SIGNATURE signature

                set container [Container_Of_WebElements new $driver $list_of_selenium_IDs]
                trace add variable signature unset [list ::apply [list args [list $container destroy]]]
            }
            return $container
        }
        
        method is_select_element {element_ID} {

            set tag_name_of_element [my tag_name $element_ID]
            if {[string tolower $tag_name_of_element] eq "select"} {
                return 1
            } else {
                return 0
            }
        }
                
		method is_displayed {element_ID} {
			# Whether the element would be visible to a user
		
			return [my execute_and_get_value $Command(IS_ELEMENT_DISPLAYED) id $element_ID]
		}
		
		method tag_name {element_ID} {
			# Gets this element's tagName property.
		
			return [my execute_and_get_value $Command(GET_ELEMENT_TAG_NAME) id $element_ID]
		}
		
	
		method get_visible_text {element_ID} {
			# Gets the visible text of the element.
		
			return [my execute_and_get_value $Command(GET_ELEMENT_TEXT) id $element_ID]
		}
		
		method get_text {element_ID} {
			# Gets the text of the element.

            if {[dict get [my current_capabilities] browserName] eq "internet explorer"} {
                if {$w3c_compliant} {
                    return [my execute_and_get_value $Command(GET_ELEMENT_PROPERTY) name innerText id $element_ID]
                } else {
                    return [my execute_and_get_value $Command(GET_ELEMENT_ATTRIBUTE) name innerText id $element_ID]
                }
            } else {
                if {$w3c_compliant} {
                    return [my execute_and_get_value $Command(GET_ELEMENT_PROPERTY) name textContent id $element_ID]
                } else {
                    return [my execute_and_get_value $Command(GET_ELEMENT_ATTRIBUTE) name textContent id $element_ID]
                }
            }
		}

		method submit_form {element_ID} {
			# Submits a form.

            if {$w3c_compliant} {
                set form [my find_element -xpath ./ancestor-or-self::form -root $element_ID]
                my execute_script {
                    var e = arguments[0].ownerDocument.createEvent('Event');
                    e.initEvent('submit', true, true);
                    if (arguments[0].dispatchEvent(e)) { arguments[0].submit() }} -arguments [list element $form]
            } else {
                my execute $Command(SUBMIT_ELEMENT) id $element_ID
            }
		}
		
		method clear_text {element_ID} {
			# Clears the text if it's a text entry element.
		
			my execute $Command(CLEAR_ELEMENT) id $element_ID
		}
		
		method get_attribute {element_ID attribute_name} {
			# Gets the given attribute or property of the element.
			# 
			# This method will return the value of the given property if this is set,
			# otherwise it returns the value of the attribute with the same name if
			# that exists, or None.
			# 
			# :Args:
			# - name - Name of the attribute/property to retrieve.
			# 
			# Example::
			# 
			# # Check if the "active" CSS class is applied to an element.
			#	set class_attribute	[$driver get_element_attribute $target_element class]
			# 	set is_active [expr {[string first $class_attribute active]!=-1}]
		
			return [my execute_and_get_value $Command(GET_ELEMENT_ATTRIBUTE) name $attribute_name id $element_ID]
		}
		
		method is_selected {element_ID} {
			# Whether the element is selected.
			# 
			# Can be used to check if a checkbox or radio button is selected.
		
			return [my execute_and_get_value $Command(IS_ELEMENT_SELECTED) id $element_ID]
		}
		
		method is_enabled {element_ID} {
			# Whether the element is enabled.
		
			return [my execute_and_get_value $Command(IS_ELEMENT_ENABLED) id $element_ID]
		}
		
		method location_once_scrolled_into_view {element_ID} {
			# CONSIDERED LIABLE TO CHANGE WITHOUT WARNING. Use this to discover where on the screen an
			# element is so that we can click it. This method should cause the element to be scrolled
			# into view.
			# 
			# Returns the top lefthand corner location on the screen, or None if the element is not visible
		
			return [my execute_and_get_value $Command(GET_ELEMENT_LOCATION_IN_VIEW) id $element_ID]			
		}
		
		method size {element_ID} {
			# Returns the size of the element

			return [my execute_and_get_value $Command(GET_ELEMENT_SIZE) id $element_ID]
		}
		
		method css_property {element_ID property_name} {
			# Returns the value of a CSS property

			return [my execute_and_get_value $Command(GET_VALUE_OF_CSS_PROPERTY) propertyName $property_name id $element_ID]
		}
		
	
		method get_location {element_ID} {
			# Returns the location of the element in the renderable canvas
		
			return [my execute_and_get_value $Command(GET_ELEMENT_LOCATION) id $element_ID]			
		}
		
		method get_rect {element_ID} {
			# Returns a dictionary with the size and location of the element

			return [my execute_and_get_value $Command(GET_ELEMENT_RECT) id $element_ID]
		}
		
		method send_keys {element_ID string_of_keys} {
			# Simulates typing into the element.
			# 
			# :Args:
			# - value - A string for typing, or setting form fields.  For setting
			# file inputs, this could be a local file path.
			# 
			# Use this to send simple key events or to fill out form fields::
			# 
			# set form_textfield [$driver find_element -name username]
			# $driver send_keys -el $form_textfield -string admin
			# $driver send_keys admin $form_textfield

			my execute $Command(SEND_KEYS_TO_ELEMENT) id $element_ID value [split $string_of_keys ""] text $string_of_keys
		}
        
        method typewrite {string_of_keys} {
            my execute $Command(TYPEWRITE) value [split $string_of_keys ""]
		}
        
        method select_element {element_ID command_var} {
           upvar $command_var select_element
           set select_element [Select_Element [self] $element_ID]
           
           trace add variable select_element unset "$select_element destroy"
        }
        
        method freeze {varname} {
            # freeze element or container of webelements

            uplevel $varname obj
            trace remove variable obj unset [list [self namespace]::destroy_obj $obj]
        }
		
		method current_url {} {
			# Gets the URL of the current page.
			# 
			# :Usage:
			# 	driver current_url

			return [my execute_and_get_value $Command(GET_CURRENT_URL)]
		}
		
		method page_source {} {
			# Gets the source of the current page.
			# 
			# :Usage:
			# 	driver page_source

			return [my execute_and_get_value $Command(GET_PAGE_SOURCE)]
		}
		
		method close {} {
			# Closes the current window.
			# 
			# :Usage:
			# 	driver close

			my execute $Command(CLOSE)
		}
		
		method quit {} {
			# Quits the driver and closes every associated window.
			# 
			# :Usage:
			# 	driver quit

			try {
				my execute $Command(QUIT) sessionId $session_ID
			} finally {
				my stop_client
			}

		}
		
		method current_window_handle {} {
			# Returns the handle of the current window.
			# 
			# :Usage:
			# 	driver current_window_handle
		
			return [my execute_and_get_value $Command(GET_CURRENT_WINDOW_HANDLE)]
		}
		
		method window_handles {} {
			# Returns the handles of all windows within the current session.
			# 
			# :Usage:
			# 	driver window_handles

			return [my execute_and_get_value  $Command(GET_WINDOW_HANDLESS)]
		}
		
		method maximize_window {} {
			# Maximizes the current window that driver is using
            if {$w3c_compliant} {
                my execute $Command(W3C_MAXIMIZE_WINDOW)
            } else {
                my execute $Command(MAXIMIZE_WINDOW) windowHandle current
            }
		}
		
		#Navigation
		method back {} {
			# Goes one step backward in the browser history.
			# 
			# :Usage:
			# 	driver back

			my execute $Command(GO_BACK)
		}
		
		method forward {} {
			# Goes one step forward in the browser history.
			# 
			# :Usage:
			# 	driver forward

			my execute $Command(GO_FORWARD)
		}
		
		method refresh {} {
			# Refreshes the current page.

			my execute $Command(REFRESH)
		}
		
		# Options
		method get_cookies {} {

			# Returns a set of dictionaries, corresponding to cookies visible in the current session.
			#
			# :Usage:
			# 	driver get_cookies

			return [my execute_and_get_value $Command(GET_ALL_COOKIES)]
		}
		
		method get_cookie {name} {
			# Get a single cookie by name. Returns the cookie if found, None if not.
			# 
			# :Usage:
			# driver get_cookie 'my_cookie'

			set cookies [my get_cookies]
			foreach cookie $cookies {
				if {[dict get $cookie name]	eq $name} { return $cookie }
			}
			
			return
		}
		
		method delete_cookie {name} {
			# Deletes a single cookie with the given name.

			my execute $Command(DELETE_COOKIE) name $name
		}
		
		method delete_all_cookies {} {
			# Delete all cookies in the scope of the session.

			my execute $Command(DELETE_ALL_COOKIES)
		}
		
		method add_cookie {args} {
			# Adds a cookie to your current session.
			# 
			# :Args:
			# - cookie_dict: A dict object, with required keys - "name" and "value";
			# optional keys - "path", "domain", "secure", "expiry"
			#
			# Key 		Type 		Description
			# name 		string 		The name of the cookie.
			# value 	string 		The cookie value.
			# path 		string 		(Optional) The cookie path.1
			# domain 	string 		(Optional) The domain the cookie is visible to.1
			# secure 	boolean 	(Optional) Whether the cookie is a secure cookie.1
			# httpOnly 	boolean 	(Optional) Whether the cookie is an httpOnly cookie.1
			# expiry 	number 		(Optional) When the cookie expires, specified in seconds since midnight, January 1, 1970 UTC.1
			# 
			# Usage:
			# 	driver add_cookie  name foo  value bar
			# 	driver add_cookie  name foo  value bar  path /
			# 	driver add_cookie  name foo  value bar  path /  secure true

						
			set cookie [dict create]
			
			for {parameter_name value} $args {
				switch -exact $parameter_name {
					-name {
						dict set cookie name $value
					}
					-value {
						dict set cookie value $value
					}
					-path {
						dict set cookie path $value
					}
					-domain {
						dict set cookie domain $value
					}
					-secure {
						dict set cookie secure $value
					}
					-domain {
						dict set cookie domain $value
					}
					-httpOnly {
						dict set cookie httpOnly $value
					}
					-expiry {
						dict set cookie expiry $value
					}
					default {
						error "Invalid parameter for cookie: $parameter_name"
					}
				}
			}
			
			if {![dict exists  $cookie name] || ![dict exists  $cookie value]} {
				error "'-name' and '-value' are mandatory cookie parameters"
			}
			
			my execute $Command(ADD_COOKIE) cookie $cookie
		}
		
		# Timeouts
		method implicitly_wait {time_to_wait} {
			# Sets a sticky timeout to implicitly wait for an element to be found,
			# or a command to complete. This method only needs to be called one
			# time per session. To set the timeout for calls to
			# execute_async_script, see set_script_timeout.
			# 
			# :Args:
			# - time_to_wait: Amount of time to wait (in seconds)
			# 
			# :Usage:
			# 	driver implicitly_wait 30
            
            if {$w3c_compliant} {
                my execute $Command(SET_TIMEOUTS) ms [expr $time_to_wait * 1000] type implicit
            } else {
                my execute $Command(IMPLICIT_WAIT) ms [expr $time_to_wait * 1000]
            }
		}
		
		method set_script_timeout {time_to_wait} {
			# Set the amount of time that the script should wait during an
			# execute_async_script call before throwing an error.
			#
			# :Args:
			# - time_to_wait: The amount of time to wait (in seconds)
            
            if {$w3c_compliant} {
                my execute $Command(SET_TIMEOUTS) ms [expr $time_to_wait * 1000] type script
            } else {
                my execute $Command(SET_SCRIPT_TIMEOUT)	ms [expr $time_to_wait * 1000]
            }
		}

		
		method set_page_load_timeout {time_to_wait} {
			# Set the amount of time to wait for a page load to complete
			# before throwing an error.
			# 
			# :Args:
			# - time_to_wait: The amount of time to wait
			# 
			# :Usage:
			# driver set_page_load_timeout 30

			my execute $Command(SET_TIMEOUTS) ms [expr $time_to_wait * 1000] type {page load}
		}

		method current_capabilities {} {
			# returns the drivers current desired capabilities being used

			return $current_capabilities
		}

		method get_screenshot_as_file {filename {element_ID ""}} {
			# Gets the screenshot of the current window. Returns False if there is
			# any IOError, else returns True. Use full paths in your filename.
			# 
			# :Args:
			# - filename: The full path you wish to save your screenshot to.
			# 
			# :Usage:
			# 	driver get_screenshot_as_file /Screenshots/foo.png

			set png [my get_screenshot_as_png $element_ID]
			
			if { [catch {open $filename wb} fileId] } {
				return false
			} else {
				puts -nonewline $fileId $png
                close $fileId
                
				return true
			}
			
		}
		
		forward save_screenshot get_screenshot_as_file
		
		method get_screenshot_as_png {{element_ID ""}} {
			# Gets the screenshot of the current window as a binary data.

			return [::base64::decode [my get_screenshot_as_base64 $element_ID]]
		}
		
		method get_screenshot_as_base64 {{element_ID ""}} {
			# Gets the screenshot of the current window as a base64 encoded string
			# which is useful in embedded images in HTML.
			# 
			# :Usage:
			# 	driver get_screenshot_as_base64

			            if {$element_ID eq ""} {
                return [my execute_and_get_value $Command(SCREENSHOT)]
			} else {
				return [my execute_and_get_value $Command(ELEMENT_SCREENSHOT) id $element_ID]
			}
		}
		
		method set_window_size {width height {windowHandle current}} {
			# Sets the width and height of the current window. (window.resizeTo)
			# 
			# :Args:
			# - width: the width in pixels to set the window to
			# - height: the height in pixels to set the window to
			# 
			# :Usage:
			# 	driver set_window_size 800 600

			my execute $Command(SET_WINDOW_SIZE) width $width height $height windowHandle $windowHandle
		}
		
		method get_window_size { {windowHandle current}} {
			# Gets the width and height of the current window.
			# 
			# :Usage:
			# 	driver get_window_size

            if {$w3c_compliant} {
                return [my execute_and_get_value $Command(W3C_GET_WINDOW_SIZE)]
            } else {
                return [my execute_and_get_value $Command(GET_WINDOW_SIZE) windowHandle $windowHandle]
            }
		}
		
		method set_window_position {x y {windowHandle current}} {
			# Sets the x,y position of the current window. (window.moveTo)
			# 
			# :Args:
			# - x: the x-coordinate in pixels to set the window position
			# - y: the y-coordinate in pixels to set the window position
			# 
			# :Usage:
			# 	driver set_window_position 0 0

			my execute $Command(SET_WINDOW_POSITION) x $x y $y windowHandle $windowHandle
		}
		
		method get_window_position {windowHandle current} {
			# Gets the x,y position of the current window.

			return [my execute_and_get_value $Command(GET_WINDOW_POSITION) windowHandle $windowHandle]
		}
		
		method get_screen_orientation {} {
			# Gets the current orientation of the device

			return [my execute_and_get_value $Command(GET_SCREEN_ORIENTATION)]
		}
		
		method set_screen_orientation {value} {
			# Sets the current orientation of the device
			# 
			# :Args:
			# - value: orientation to set it to.
			# 
			# :Usage:
			# 	driver set_orientation "landscape"

			set value [string toupper value] 

			if { $value in [list LANDSCAPE PORTRAIT]} {
				my execute $Command(SET_SCREEN_ORIENTATION) orientation $value
			} else {
				throw $Exception(WebdriverException) "You can only set the orientation to 'LANDSCAPE' and 'PORTRAIT'"
			}
		}

		method available_log_types {} {
			# Gets a list of the available log types
			#
			# :Usage:
			# 	driver log_types

			return [my execute_and_get_value $Command(GET_AVAILABLE_LOG_TYPES)]
		}
		
		method get_log {log_type} {
			# Gets the log for a given log type
			#
			#:Args:
			# - log_type: type of log that which will be returned
			#
			#:Usage:
			#	driver get_log browser
			#	driver get_log driver
			#	driver get_log client
			#	driver get_log server
			
			return [my execute_and_get_value $Command(GET_LOG) type $log_type]
		}
		
		method alert_text {} {
			# Gets the text of the Alert.
		
			return [my execute_and_get_value $Command(GET_ALERT_TEXT)]
		}
		
		method dismiss_alert {} {
			# Dismisses the alert available.
		
			my execute $Command(DISMISS_ALERT))
		}
		
		method accept_alert {} {
			# Accepts the alert available.
			# 
			# Usage::
			# 	driver accept_alert # Confirm a alert dialog.
		
			my execute $Command(ACCEPT_ALERT))
		}
		
		method send_keys_to_alert {keysToSend} {
			# Send Keys to the Alert.
			# 
			# :Args:
			# - keysToSend: The text to be sent to Alert.
		
			my execute $Command(SET_ALERT_VALUE) text $keysToSend
		}
		
		method get_app_cache_status {} {
			# Returns a current status of application cache.
		
			set status [my execute_and_get_value $Command(GET_APP_CACHE_STATUS)]
				
			return $StatusCache($status)
		}
		
	
		method switch_to_default_frame {} {
			# Switch focus to the default frame.
			# 
			# :Usage:
			# 	driver switch_to_default_frame
	
			my execute $Command(SWITCH_TO_FRAME) id null
		}
	
		method switch_to_frame {by frame_reference} {
			# Switches focus to the specified frame, by index, name, or webelement.
			# 
			# :Args:
			# - frame_reference: The name of the window to switch to, an integer representing the index,
			# or a webelement that is an (i)frame to switch to.
			# 
			# :Usage:
			# 	driver switch_to_frame -name $frame_name
			# 	driver switch_to_frame -index 1
			# 	driver switch_to_frame -element [[driver find_elements_by_tag_name iframe] index 0]
	
			switch -exact -- $by {
				-index {
					set parameters [list id [compile_to_json number $frame_reference]]
				}
				-name {

				    if {!$w3c_compliant} {
				        set parameters [list id [compile_to_json string $frame_reference]]
				    } else {
				        if [catch {my find_element -name $frame_reference} frame_elem] {
				            if [catch {my find_element -id $frame_reference} frame_elem] {
				                error "Can not find frame $frame_reference"
				            }
				        }
				        set parameters [list id [compile_to_json dict [dict create ELEMENT $frame_elem element-6066-11e4-a52e-4f735466cecf $frame_elem]]]    
				    }				}
				-element {
 					set parameters [list id [compile_to_json dict [dict create ELEMENT $frame_reference element-6066-11e4-a52e-4f735466cecf $frame_reference]]]
					                       }
				default {
					error "Invalid switch type reference for switch_to_frame: $type"
				}
			}
			
			my execute $Command(SWITCH_TO_FRAME) {*}$parameters
		}
	
		method switch_to_parent_frame {} {
			# Switches focus to the parent context. If the current context is the top
			# level browsing context, the context remains unchanged.
			# 
			# :Usage:
			# 	driver switch_to_parent_frame
	
			my execute $Command(SWITCH_TO_PARENT_FRAME)
		}
	
		method switch_to_window {window_name} {
			# Switches focus to the specified window.
			# 
			# :Args:
			# - window_name: The name or window handle of the window to switch to.
			# 
			# :Usage:
			# 	driver switch_to_window main
	
			my execute $Command(SWITCH_TO_WINDOW) name $window_name
		}
        
        method move_mouse_to {{xoffset {}} {yoffset {}} {webelement {}}} {
            # Move the mouse by an offset of the specificed element. 
            # If no element is specified, the move is relative to the current mouse cursor
            # If an element is provided but no offset, the mouse will be moved to the center of the element. 
            # If the element is not visible, it will be scrolled into view.
			# 
			# :Args:
            #   - element: ID assigned to the webelement to move to, as described in the WebElement JSON Object. 
            #   If not specified or is null, the offset is relative to current position of the mouse.
            #
            #   - xoffset: X offset to move to, relative to the top-left corner of the element. 
            #   If not specified, the mouse will move to the middle of the element.
            #
            #   - yoffset: Y offset to move to, relative to the top-left corner of the element. 
            #   If not specified, the mouse will move to the middle of the element.
			# 
			# :Usage:
			# 	driver move_mouse_to 10 21 $element
	
            my execute $Command(MOVE_TO) xoffset $xoffset yoffset $yoffset element $webelement 
        }
		

		# LOS SIGUIENTES METODOS SE TIENEN QUE REVISAR
		method network_connection {} {
			# ConnectionType is a bitmask to represent a device's network connection
			# Data 	| WIFI | Airplane
			# 0 	  0 	 1 			== 1
			# 1 	  1 	 0 			== 6
			# 1 	  0 	 0 			== 4
			# 0 	  1 	 0			== 2
			# 0 	  0 	 0 			== 0
			#
			# Giving "Data" the first bit positions in order to give room for the future of enabling
			# specific types of data (Edge / 2G, 3G, 4G, LTE, etc) if the device allows it.
			# 
			
			set mask [my execute_and_get_value $Command(GET_NETWORK_CONNECTION)]
			return [my Convert_mask_to_connection_name $mask]
		}
		
		method Convert_mask_to_connection_name {mask} {
			set connectionNames [list]
			
			if {(mask & 1) == 1} {
				lappend connectionNames AIRPLANE_MODE
			} elseif {(mask & 2) == 1} {
				lappend connectionNames WIFI_NETWORK
			} elseif {(mask & 4) == 1} {
				lappend connectionNames DATA_NETWORK
			}

			return $connectionNames
			
		}
		
		method set_network_connection args {
			# Set the Connection type
			# Not all connection type combinations are valid for an individual type of device
			# and the remote endpoint will make a best effort to set the type as requested 
			
			set mask 0
			foreach connection $args {
				if {$connection eq AIRPLANE_MODE} {
					incr mask 1
				} elseif {$connection eq WIFI_NETWORK} {
					incr mask 2
				} elseif {$connection eq DATA_NETWORK} {
					incr mask 4
				} else {
					error "Invalid connection name: $connection"
				}
			}
			
			set returned_mask [my execute_and_get_value $Command(SET_NETWORK_CONNECTION) name network_connection parameters [dict create type $mask]]
			
			return [my Convert_mask_to_connection_name $returned_mask]

		}        
        
		destructor {
            if {[info exists remote_connection]} {
                $remote_connection destroy
            }
            
            if {[info exists error_handler]} {
                $error_handler destroy
            }
		}
		
	}
}

