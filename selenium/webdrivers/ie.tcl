package provide selenium::ie 0.1

package require selenium
package require selenium::utils::port
package require selenium::utils::process

namespace eval ::selenium::webdrivers::ie {
	namespace export IEDriver

	oo::class create IEDriver {
		variable path_to_driver_binary parameters_to_driver port desired_capabilities pid host Exception
		superclass ::selenium::WebDriver
		
		constructor {args} {
        
            # Creates a new instance of IEDriver

            # :Args:
            # - executable_path : Path to the IEDriver
            # - port : Port the service is running on
            # - host : IP address the service port is bound
            # - logLevel : Level of logging of service, may be "FATAL", "ERROR", "WARN", "INFO", "DEBUG", "TRACE".
            #   Default is "FATAL".
            # - log : Target of logging of service, may be "stdout", "stderr" or file path.
            #   Default is "stdout"."""

            namespace import \
                ::selenium::utils::port::get_free_port \
                ::selenium::utils::process::kill
                	
			array set options $args
			
            set host localhost
			foreach {option_name option_value} [array get options] {
				switch -exact -- $option_name {
					-binary {
						set path_to_driver_binary $option_value
					}
					-port {
                        set port $option_value
						lappend parameters_to_driver "--port=$option_value"
					}
					-log {
						lappend parameters_to_driver "--log-file=$option_value"
					}
					-log_level	{
						lappend parameters_to_driver "--log-level=$option_value"
					}
                    -host {
                        set host $option_value
                        lappend parameters_to_driver "--host==$option_value"
                    }
					-capabilities {
						set desired_capabilities $option_value
					}
					default {
						return -code error "Invalid option: $option_name"
					}
					
				}
			}
			
			if {![info exists path_to_driver_binary]} { 
                set path_to_driver_binary IEDriverServer.exe
			}
			
			if {![info exists desired_capabilities]} { 
				set desired_capabilities [::selenium::desired_capabilities INTERNETEXPLORER]
			} else {
				if {![dict exists $desired_capabilities browsername]} {
					dict set desired_capabilities browsername {internet explorer}
				}
			}

            if {![info exists port]} {
				set port [get_free_port]		
				lappend parameters_to_driver "--port=$port"
			}

			next [my service_url] $desired_capabilities
			
		}
		
		method service_url {} {
			return "http://$host:$port"
		}
		
		method start_client {} {
            
			if { [catch {set pid [exec $path_to_driver_binary {*}$parameters_to_driver &]}] } {
				throw $Exception(WebdriverException) {IEDriverServer.exe needs to be available in the path.\
				Please download from http://selenium-release.storage.googleapis.com/index.html and read up at https://github.com/SeleniumHQ/selenium/wiki/InternetExplorerDriver}
			} 
			if {![my wait_until_connectable $port]} {
                error "Can not connect to the IEDriver"
            }
			return $pid
		}
		
		method stop_client {} {
			::http::geturl "[my service_url]/shutdown"
			
			my wait_until_not_connectable $port

			catch {kill $pid}
		}

	}

}

namespace eval ::selenium {
	namespace import ::selenium::webdrivers::ie::IEDriver
	namespace export IEDriver
}
