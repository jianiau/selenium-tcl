package provide selenium::chrome 0.1

package require selenium
package require selenium::utils::port
package require selenium::utils::process

namespace eval ::selenium::webdrivers::chrome {
	namespace export ChromeDriver chromeOptions

	proc chromeOptions {args} {
		set chromeOptions [dict create]

		foreach {optionName optionValue} $args {
			switch -exact -- $optionName {
				-browser_args {
					# ARGUMENTS: list of strings of command line arguments for the chrome binary
					# DESCRIPTION: List of command-line arguments to use when starting Chrome. 
					# Arguments with an associated value should be separated by a '=' sign
					# Example: ['start-maximized', 'user-data-dir=/tmp/temp_profile'])
					dict set chromeOptions args $optionValue
				}
				-browser_binary {
					# ARGUMENTS: string containing the path to the chrome executable
					# DESCRIPTION: Path to the Chrome executable to use (on Mac OS X, this should be the 
					# actual binary, not just the app. e.g., '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome')
					
					dict set chromeOptions binary $optionValue
				}
				-extension {
					# ARGUMENTS: list of strings
					# DESCRIPTION: A list of Chrome extensions to install on startup.
					# Each item in the list should be a base-64 encoded packed Chrome extension (.crx)
					if [file exists $optionValue] {
						set channelId [open $optionValue r]
						# set tiene que mirar
						set extension [binary encode base64 [read $channelId]]

						close $channelId
						dict set chromeOptions extensions lappend $extension
					} else {
						error "Path to the extension doesn't exist"
					}
				}
				-encoded_extension {
					# ARGUMENTS: Base64 encoded string with extension data
					# DESCRIPTION: Adds Base64 encoded string with extension data to a list that will be used 
					# to extract it to the ChromeDriver
					
					dict set chromeOptions extensions lappend $optionValue
				}
				-local_state {
					# ARGUMENTS: dictionary
					# DESCRIPTION: A dictionary with each entry consisting of the name of the 
					# preference and its value. These preferences are applied to the Local State
					# file in the user data folder.
					dict set chromeOptions localState $optionValue
				}
				-preferences {
					# DESCRIPTION: A dictionary with each entry consisting of the name of the
					# preference and its value. These preferences are only applied to the user
					# profile in use. See the 'Preferences' file in Chrome's user data directory 
					# for examples.
					dict set chromeOptions prefs $optionValue
				}
				-detach {
					# ARGUMENTS: A boolean
					# DESCRIPTION: If false, Chrome will be quit when ChromeDriver is killed, regardless of 
					# whether the session is quit. If true, Chrome will only be quit if the 
					# session is quit (or closed). Note, if true, and the session is not quit, 
					# ChromeDriver cannot clean up the temporary user data directory that the 
					# running Chrome instance is using.
					
					dict set chromeOptions detach [expr $optionValue]
				}
				-debugger_address {
					# ARGUMENTS: A string of the form <hostname/ip:port>
					# DESCRIPTION: An address of a Chrome debugger server to connect to, in the 
					# form of <hostname/ip:port>, e.g. '127.0.0.1:38947'
					
					dict set chromeOptions debuggerAddress $optionValue
				}
				-exclude_switches {
					# ARGUMENTS: List of switches of the chome executable without the prefix '--'
					# DESCRIPTION: List of Chrome command line switches to exclude that ChromeDriver by 
					# default passes when starting Chrome. Do not prefix switches with --.
					
					dict set chromeOptions excludeSwitches $optionValue
				}
				-mini_dump_path {
					# ARGUMENTS: String indicating a path to a directory
					# DESCRIPTION: Directory to store Chrome minidumps. 
					# (Supported only on Linux.)
					dict set chromeOptions minidumpPath $optionValue
				}
				-mobile_emulation {
					# ARGUMENTS: Dictionary with options for mobile emulation
					# DESCRIPTION: A dictionary with either a value for “deviceName,” or values 
					# for “deviceMetrics” and “userAgent.”
					dict set chromeOptions mobileEmulation $optionValue
				}
				-logging_preferences {
					# ARGUMENTS: Dictionary of preferences for logging
					# DESCRIPTION: An optional dictionary that specifies performance logging  preferences
					#
					# Name							Type				Default	Description
					# enableNetwork 				boolean 			true 	Whether or not to collect events from Network domain.
					# enablePage	 				boolean 			true 	Whether or not to collect events from Page domain.
					# enableTimeline			 	boolean 			true 	(false if tracing is enabled) 	Whether or not to collect events from Timeline domain. Note: when tracing is enabled, Timeline domain is implicitly disabled, unless enableTimeline is explicitly set to true.
					# tracingCategories 			string 				""	 	A comma-separated string of Chrome tracing categories for which trace events should be collected. An unspecified or empty string disables tracing.
					# bufferUsageReportingInterval 	positive integer 	1000 	The requested number of milliseconds between DevTools trace buffer usage events. For example, if 1000, then once per second, DevTools will report how full the trace buffer is. If a report indicates the buffer usage is 100%, a warning will be issued.
					
					dict set chromeOptions perfLoggingPrefs $optionValue
				}
			}
		}
        
        return $chromeOptions
	}


	oo::class create ChromeDriver {
		variable path_to_driver_binary parameters_to_driver port desired_capabilities pid Exception
		superclass ::selenium::WebDriver
		
		constructor {args} {
            namespace import \
                ::selenium::utils::port::get_free_port \
                ::selenium::utils::process::kill \
                ::selenium::webdrivers::chrome::chromeOptions
                	
			array set options $args
			
            set chrome_options [list]

			foreach {option_name option_value} [array get options] {
				switch -exact -- $option_name {
					-binary {
						set path_to_driver_binary $option_value
					}
					-port {
                        set port $option_value
						lappend parameters_to_driver "--port=$option_value"
					}
					-verbose {
						lappend parameters_to_driver "--verbose"
					}
					-log {
						lappend parameters_to_driver "--log-path=$option_value"
					}
					-url_base	{
						lappend parameters_to_driver "--url-base=$option_value"
					}
					-capabilities {
						set desired_capabilities $option_value
					}
                    -http_proxy {
                        lappend browser_args proxy-server=http://$option_value
                    }
                    -browser_args {
                        lappend browser_args {*}$option_value
                    }
                    -browser_binary -
                    -extension -
                    -enconded_extension -
                    -local_state -
                    -preferences -
                    -detach -
                    -debugger_address -
                    -exclude_switches -
                    -mini_dump_path -
                    -mobile_emulation -
                    -logging_preferences {
                        lappend chrome_options $option_name $option_value
					}
					default {
						return -code error "Invalid option: $option_name"
					}
				}
			}
			
            if {[info exists browser_args]} {
                lappend chrome_options -browser_args $browser_args
            }
            
			if {![info exists path_to_driver_binary]} {
                if {$::tcl_platform(platform) eq "windows"} {
                    set path_to_driver_binary chromedriver.exe
                } else {
                    set path_to_driver_binary chromedriver
                }
			}
            
			if {![info exists desired_capabilities]} { 
				set desired_capabilities [::selenium::desired_capabilities CHROME]

			}
            
            if {[llength chrome_options] != 0} { 
                dict set desired_capabilities chromeOptions [chromeOptions {*}$chrome_options]
            }

            if {![info exists port]} {
				set port [get_free_port]		
				lappend parameters_to_driver "--port=$port"
			}

			next [my service_url] $desired_capabilities
			
		}
		
		method service_url {} {
			return "http://localhost:$port"
		}
		
		method start_client {} {
            
			if { [catch {set pid [exec $path_to_driver_binary {*}$parameters_to_driver &]}] } {
				throw $Exception(WebdriverException) {ChromeDriver executable needs to be available in the path.\
				Please download from http://chromedriver.storage.googleapis.com/index.html\
				and read up at http://code.google.com/p/selenium/wiki/ChromeDriver}
			} 
			if {![my wait_until_connectable $port]} {
                error "Can not connect to the ChromeDriver"
            }
			return $pid
		}
		
		method stop_client {} {
			::http::geturl "http://127.0.0.1:$port/shutdown"
			
			my wait_until_not_connectable $port

			catch {kill $pid}
		}

	}

}

namespace eval ::selenium {
	namespace import ::selenium::webdrivers::chrome::ChromeDriver ::selenium::webdrivers::chrome::chromeOptions
	namespace export ChromeDriver chromeOptions
}
