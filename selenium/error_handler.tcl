
namespace eval ::selenium {

# Error codes defined in the WebDriver wire protocol.
# Keep in sync with org.openqa.selenium.remote.errorCodes and errorcodes.h

	variable SUCCESS 0
	variable errorCode

    set errorCode(2) $Exception(ConnectionRefused)
	set errorCode(6) $Exception(NoSuchDriver)
	set errorCode(7) $Exception(NoSuchElement)
	set errorCode(8) $Exception(NoSuchFrame)
	set errorCode(9) $Exception(UnknownCommand)
	set errorCode(10) $Exception(StaleElementReference)
	set errorCode(11) $Exception(ElementNotVisible)
	set errorCode(12) $Exception(InvalidElementState)
	set errorCode(13) $Exception(UnknownError)
	set errorCode(15) $Exception(ElementIsNotSelectable)
	set errorCode(17) $Exception(JavaScriptError)
	set errorCode(19) $Exception(XPathLookupError)
	set errorCode(21) $Exception(Timeout)
	set errorCode(23) $Exception(NoSuchWindow)
	set errorCode(24) $Exception(InvalidCookieDomain)
	set errorCode(25) $Exception(UnableToSetCookie)
	set errorCode(26) $Exception(UnexpectedAlertOpen)
	set errorCode(27) $Exception(NoAlertOpen)
	set errorCode(28) $Exception(ScriptTimeout)
	set errorCode(29) $Exception(InvalidElementCoordinates)
	set errorCode(30) $Exception(IMENotAvailable)
	set errorCode(31) $Exception(IMEEngineActivationFailed)
	set errorCode(32) $Exception(InvalidSelector)
	set errorCode(33) $Exception(SessionNotCreated)
	set errorCode(34) $Exception(MoveTargetOutOfBounds)
	
	# Invalid Xpath selector
	set errorCode(51) $Exception(InvalidSelector)

	# Invalid xpath selector return typer
	set errorCode(52) $Exception(InvalidSelector)
	set errorCode(405) $Exception(InvalidCommandMethod)

	set errorCode(400) $Exception(MissingCommandParameters)
	
	oo::class create ErrorHandler {
		variable message stacktrace screen errorCode SUCCESS Exception
		# Handles errors returned by the WebDriver server
		constructor {} {
			namespace upvar ::selenium Exception [self]::Exception
			
			namespace upvar ::selenium errorCode [self]::errorCode
			namespace upvar ::selenium SUCCESS [self]::SUCCESS
		}

		method message {} {
			return $message
		}
	
		method stacktrace {} {
			return $stacktrace
		}
	
		method screen {} {
			return $screen
		}

		method check_response {session_ID command_name command_parameters response} {
	
			# Checks that a JSON response from the WebDriver does not have an error.
			#
			# :Args:
			# - response - The JSON response from the WebDriver server as a dictionary
			#   object.
			#
			# :Raises: If the response contains an error message.

            lassign $response status json_answer
            
			if {$status == $::selenium::RESPONSE_SUCCESS} {
				return $json_answer
			}

            if {[dict exists $json_answer status]} {
                set status [dict get $json_answer status]
                if {[info exists errorCode($status)]} {
                    set exception_code $errorCode($status)
                } else {
                    set exception_code $Exception(WebdriverException)
                }
                
                if {[dict exists json_answer value]} {
                    set exception_info [dict get $json_answer value]
                } else {
                    set exception_info $json_answer
                }
            } elseif {[dict exists $json_answer error]} {
                set exception_name ""
				foreach word [split [dict get $json_answer error] " "] {
					append exception_name [string totitle $word]
				}

                if {[info exists Exception($exception_name)]} {
                    set exception_code $Exception($exception_name)
                } else {
                    set exception_code $Exception(WebdriverException)
                }
				set exception_info $json_answer
            } else {
				set exception_code $Exception(WebdriverException)
                set exception_info ""
			}

            set error_message "\n\nWebdriver exception\n-------------------"
            append error_message "\ncommand name: $command_name"
            
            if {$command_parameters ne ""} {
                append error_message "\ncommand parameters: $command_parameters"
            }
            
            if {$session_ID ne ""} {
                append error_message "\nsession ID: $session_ID"
            }
            
            
            if { $exception_code eq $Exception(UnexpectedAlertOpen) &&  [dict exists $exception_info alert]} {
				append error_message "\nalert: [dict get $exception_info alert]"
			} else {
                if {[dict exists $exception_info message]} {
                    append error_message "\nbrowser message: [dict get $exception_info message]"
                }
            }
            
            if {[dict exists $exception_info html]} {
				append error_message "\nhtml:\n[dict get $exception_info html]"
			}
		
			if {[dict exists $exception_info screen]} {
				set screen [dict get $exception_info screen]
                append error_message "\nscreen: $screen"
			} else {
				set screen ""				
			}

			set stacktrace [list]
		
			if { [dict exists $exception_info stackTrace] } {
				set stackTrace_frames [dict get $exception_info stackTrace]
				
				foreach frame $stackTrace_frames {
                    set line [expr {[dict exists $frame lineNumber] ?  [dict get $frame lineNumber] : ""}]
                    set file_location [expr {[dict exists $frame fileName] ? [dict get $frame fileName] : "<anonymous>"}]
                                    
                    set method_name [expr {[dict exists $frame methodName] ? [dict get $frame methodName] : "<anonymous>"}]
					if [dict exists $frame className] {
						set method_name "[dict get $frame className].$method_name"
					}
					
                    if {$line eq ""} {
                        set info_error "$method_name ($file_location)"
                    } else {
                        set info_error "$method_name (${file_location}:${line})"
                    }

					lappend stacktrace [dict create info $info_error frame $frame]
				}

			}
			if {[llength $stacktrace] != 0} {
                
                append error_message "\nstacktrace:\n"
                foreach stacktrace_frame $stacktrace {
                    append error_message "    at [dict get $stacktrace_frame info]\n"
                    dict for {key value} [dict get $stacktrace_frame frame] {
                        append error_message "        $key: $value\n"
                    }

                    append error_message "\n"
                }
            }
            
            append error_message "\n-------------------\n\n"
            
            throw $exception_code $error_message
		}
	}

}
