package provide selenium::phantomjs 0.1

package require selenium
package require selenium::utils::port
package require selenium::utils::process

namespace eval ::selenium::webdrivers::phantomjs {
	namespace export PhantomJSdriver

	oo::class create PhantomJSdriver {
		variable path_to_browser_binary port parameters_to_driver desired_capabilities pid log Exception
		superclass ::selenium::WebDriver
		
		constructor {args} {
            # Creates a new instance of the PhantomJS / Ghostdriver.
            #
            # Starts the service and then creates new instance of the driver.
            #
            # :Args:
            #   -binary: Path to PhantomJS executable. If the default is used it assumes the executable is in the $PATH
            #   -port: Port you would like the service to run, if left as 0, a free port will be found.
            #   -capabilities: Dictionary object with non-browser specific
            #     capabilities only, such as "proxy" or "loggingPref".
            #   -cookie_file
            #   -useragent
            #   -log: Path for phantomjs service to log to.
            #   -log_level
            
			namespace import \
                ::selenium::utils::port::is_connectable \
                ::selenium::utils::port::get_free_port \
                ::selenium::utils::process::process_exists
						
			array set options $args
			
			foreach {option_name option_value} [array get options] {
				switch -exact -- $option_name {
					-binary {
						set path_to_browser_binary $option_value
					}
					-port {
                        set port $option_value
						lappend parameters_to_driver --webdriver=$option_value
					}
                    -log {
                        lappend parameters_to_driver --webdriver-logfile=$option_value
                    }
                    -log_level {
                        lappend parameters_to_driver --webdriver-loglevel=$option_value
                    }
                    -http_proxy {
                        lappend parameters_to_driver --proxy=$option_value --proxy-type=http
                    }
                    -socks_proxy {
                        lappend parameters_to_driver --proxy=$option_value --proxy-type=socks5
                    }
                    -proxy_auth {
                        lappend parameters_to_driver --proxy-auth=$option_value
                    }
                    -useragent {
                        set user_agent $option_value
                    }
                    -capabilities {
						set desired_capabilities $option_value
					}
                    -cookie_file {
                        lappend parameters_to_driver --cookies-file=$option_value
                    }
                    default {
						return -code error "Invalid option: $option_name"
					}
                }
            }
            
            if {![info exists path_to_browser_binary]} {
                if {$::tcl_platform(platform) eq "windows"} {
                    set path_to_browser_binary phantomjs.exe
                } else {
                    set path_to_browser_binary phantomjs
                }
			}
			
			if {![info exists desired_capabilities]} {
				set desired_capabilities [::selenium::desired_capabilities PHANTOMJS]
			} else {
				if {![dict exists $desired_capabilities browsername]} {
					dict set desired_capabilities browsername phantomjs
				}
                
                if {[dict exists $desired_capabilities proxy]} {
					set proxy [dict get $desired_capabilities proxy]
                    
                    if {[dict exists $proxy proxyType]} {
                        switch -exact [dict get $proxy proxyType] {
                            manual {
                                if {[dict exists $proxy httpProxy]} {
                                  lappend parameters_to_driver  --proxy-type=http --proxy=http://[dict get $proxy httpProxy]
                                }
                            }
                            pac {
                                return -code error {Error in desired capabilities. PhantomJS does not support Proxy PAC files}
                            }
                            system {
                                lappend parameters_to_driver --proxy-type=system
                            }
                            direct {
                                lappend parameters_to_driver --proxy-type=none
                            }
                        }
                    }
				}
			}
            
            if {[info exists user_agent]} {
                dict set desired_capabilities phantomjs.page.settings.userAgent $user_agent
            }
            
            if {![info exists port]} {
				set port [get_free_port]		
				lappend parameters_to_driver "--webdriver=$port"
			}

			next [my service_url] $desired_capabilities
        }
        
        method service_url {} {
            # Gets the url of the GhostDriver Service
            return "http://localhost:$port/wd/hub"
        }
        
        method start_client {} {
            # Starts PhantomJS with GhostDriver.
            #
            # :Exceptions:
            #   - WebDriverException : Raised either when it can't start the service or when it can't connect 
            #   to the service
            
            
			if { [catch {set pid [exec $path_to_browser_binary {*}$parameters_to_driver &]} message_error] } {
				
				throw $Exception(WebdriverException) "Unable to start phantomjs with ghostdriver. $message_error"
			} 
            
            if {![my wait_until_connectable $port]} {
                error "Can not connect to GhostDriver"
            }
			
			return $pid
		}
        
        method stop_client {} {
            # Cleans up the process
			if {[process_exists $pid]} {
                my wait_until_not_connectable $port
                catch {kill $pid}
            }
		}
        
    }
}

namespace eval ::selenium {
	namespace import ::selenium::webdrivers::phantomjs::PhantomJSdriver
	namespace export PhantomJSdriver
}
