namespace eval ::selenium {
    # Different solutions are explained here:
    #    http://www.obeythetestinggoat.com/how-to-get-selenium-to-wait-for-page-load-after-a-click.html

	namespace export wait_until wait_for_page_load

	proc wait_until {args} {
		# Calls the method provided with the driver as an argument until the return value is not false.
		#   :Args:
		#	- driver
		#		Instance of WebDriver (Ie, Firefox, Chrome or Remote)
		#	- timeout
		#		Number of seconds before timing out
		#	- pollFrequency 
		#		Sleep interval between calls. By default, it is 500 milliseconds.
		#	- ignoredExceptions
		#		List of exceptions codes ignored during calls.
		#	  	By default, it contains $Exception(NoSuchElement)
		#	- condition
		#		The method to evalute with the driver as an argument that should return a boolean expression.
		#	- errorMessage
		#		The error message to throw when time out.

		variable Exception
		
		# We set default values
		set ignored_exceptions [list $Exception(NoSuchElement)]
		set error_message "Timeout while executing wait_until procedure."
		set polling_time 500
		
		# We set the number of required options detected
		set required_options 0
		
		foreach {optionName optionValue} $args {
			switch -exact $optionName {
				-condition {
					set condition_to_eval $optionValue
					incr required_options
				}
				-driver {
					set driver $optionValue
					incr required_options
				}
				-timeout {
					set timeout $optionValue
					incr required_options
				}
				-pollFrequency {
					set polling_time $optionValue
				}
				-errorMessage {
					set error_message $optionValue
				}
				default {
					error "Invalid option: $optionName"
				}
				
			}
		}
		
		if {$required_options != 3} {
			error "-driver, -condition and -timeout are all required options"
		}	

		set end_time [expr {[clock clicks -milliseconds] + $timeout*1000}]
		
		while {[clock clicks -milliseconds] <= $end_time} {
			if {[uplevel $condition_to_eval $driver]} {
                return
            }

			after $polling_time 
		}	
		throw $Exception(Timeout) $error_message
	}

	proc wait_for_page_load {args} {
        _wait_for_page_load $args [list apply {{driver} {
            set page_state [$driver execute_javascript {return document.readyState}]
            if {$page_state eq "complete"} {
               return 1
			} else {
               return 0 
            }
        }}]
	}
    
    proc wait_for_page_load2 {args} {
        _wait_for_page_load $args [list apply {{driver id_of_old_page} {
            if {[$driver find_element -tag_name html] != $id_of_old_page} {
                return 1
			} else {
                return 0
            }
        }}] [list apply {{driver} {
            set id_of_old_page [$driver find_element -tag_name html]
            return $id_of_old_page
        }}]
	}
    
    proc _wait_for_page_load {user_options stop_condition {do_before_polling ""}} {
		# Calls the method provided with the driver as an argument until the return value is not false.
		#   :Args:
		#	- driver
		#		Instance of WebDriver (Ie, Firefox, Chrome or Remote)
		#	- timeout
		#		Number of seconds before timing out
		#	- script
		#		Script to evaluate. This script implicitly requires downloading a new web page.
		#	- timeout
		#		Number of seconds before timing out
		#	- minimumWait
		#		Time to wait before enter to the loop

		variable Exception
		
		set starting_time [clock clicks -milliseconds]
		
		# We set default values
		set polling_time 500
		set minimum_wait 2
		
		foreach {optionName optionValue} $user_options {
			switch -exact $optionName {
				-driver {
					set driver $optionValue
				}
				-script {
					set script $optionValue
				}
				-timeout {
					set timeout $optionValue
				}
				-polling_time {
					set polling_time $optionValue
				}
				-minimum_wait {
					set minimum_wait $optionValue
				}
				default {
					error "Invalid option: $optionName"
				}
				
			}
		}
		
        foreach required_option [list driver script timeout] {
            if {![info exists $required_option]} {
                error "-$required_option is a required option"
            }
        }

        if {$do_before_polling ne ""} {
            set extra_data_to_condition [{*}$do_before_polling $driver]
        }

		uplevel 2 $script		
		
		set time_waiting [expr {$starting_time + $minimum_wait*1000 - [clock clicks -milliseconds]}]
		
		if {$time_waiting > 0} { after $time_waiting }
		
		set end_time [expr {[clock clicks -milliseconds] + $timeout*1000}]

		while {[clock clicks -milliseconds] <= $end_time} {
            if {$do_before_polling ne ""} {
                if {[{*}$stop_condition $driver $extra_data_to_condition]} return
            } else {
                if {[{*}$stop_condition $driver]} return
            }

			after $polling_time 
		}

		throw $Exception(Timeout) {Too much time awaiting for page load}
	}
}
