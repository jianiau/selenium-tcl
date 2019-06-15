package provide selenium::opera 0.1

package require selenium::chrome


namespace eval ::selenium::webdrivers::opera {
	namespace export OperaDriver

	oo::class create OperaDriver {
		superclass ::selenium::ChromeDriver

		constructor {args} {
            
            array set options $args
            
            if {![info exists options(-binary)]} {
                if {$::tcl_platform(platform) eq "windows"} {
                    lappend args -binary operadriver.exe
                } else {
                    lappend args -binary operadriver
                }
			}
            
            if {![info exists options(-browser_binary)]} {
                
                if {$::tcl_platform(platform) eq "windows"} {
                    # buscar opera en registro de windows
                    lappend args -browser_binary opera.exe
                    
                } else {
                    lappend args -browser_binary /usr/bin/opera
                }
            }
            
            if {![info exists options(-capabilities)]} {
                lappend args -capabilities [::selenium::desired_capabilities OPERA]
            }
            
            next {*}$args
        }
    }
}

namespace eval ::selenium {
	namespace import ::selenium::webdrivers::opera::OperaDriver
	namespace export OperaDriver
}

