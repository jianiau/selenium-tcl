package provide selenium::firefox 0.2

package require selenium
package require selenium::utils::port
package require selenium::utils::process

package require browser_info

namespace eval ::selenium::webdrivers::firefox {
	namespace export FirefoxDriver
    
	oo::class create FirefoxDriver {
        # There is two methods to start the webdriver because from version 47 onwards. The only possibility is
        # to use geckodriver
        #       http://www.mozilla.org/en-US/firefox/47.0/releasenotes/
        #           "Selenium WebDriver may cause Firefox to crash on startup, use Marionette WebDriver instead"
        
		variable path_to_browser_binary port desired_capabilities profile profile_directory cached_env pid path_to_geckodriver path_to_log_file log_filehandler 7z proxy use_geckodriver
		superclass ::selenium::WebDriver
		
		constructor {args} {
            # :Args:
            # -browser: Path to the Firefox executable. By default, it will be detected from the standard locations.
            # -log: A file object to redirect the firefox process output to. It can be sys.stdout.
            #              Please note that with parallel run the output won't be synchronous.
            #              By default, it will be redirected to /dev/null.
            # -binary: Path to the GeckoDriver binary. 
            #           GeckoDriver provides a HTTP interface speaking the W3C WebDriver protocol to Marionette.
            # -port: Run the remote service on a specified port.
            # -7z: Path to 7z o 7za binary. Only necessary for firefox with version lower than 47.
            
            namespace import \
                ::selenium::utils::port::is_connectable \
                ::selenium::utils::port::get_free_port \
                ::selenium::utils::process::kill

            set profile_directory ""

			array set options $args
			
			foreach {option_name option_value} [array get options] {
				switch -exact -- $option_name {
                    -browser_binary {
						set path_to_browser_binary $option_value
					}
                    -browser_argument {
                        lappend browser_arguments $option_value
                    }
                    -binary {
                        set path_to_geckodriver $option_value
                    }
                    -use_geckodriver {
                        set use_geckodriver $option_value
                    }
                    -profile {
                        set profile_directory $option_value
                    }
                    -port {
                        set port $option_value
					}
                    -log {
                        set path_to_log_file $option_value
					}
                    -proxy_type {
                        # Valid values are:
                        #   DIRECT: Direct connection, no proxy (default on Windows).
                        #   MANUAL: Manual proxy settings (e.g., for httpProxy).
                        #   PAC: Proxy autoconfiguration from URL.
                        #   RESERVED_1: Never used.
                        #   AUTODETECT: Proxy autodetection (presumably with WPAD).
                        #   SYSTEM: Use system settings (default on Linux).
                        #   UNSPECIFIED: Not initialized (for internal use).

                        set proxy_type [string toupper $option_value]

                        if {$option_value ni {DIRECT MANUAL PAC RESERVED1 AUTODETECT SYSTEM UNSPECIFIED}} {
                            return -code error "Invalid proxy type: $option_value.\nValid values are: DIRECT, MANUAL, PAC, RESERVED1, AUTODETECT, SYSTEM, UNSPECIFIED"
                        }
                    }
                    -http_proxy {
                        set http_proxy $option_value
                        set proxy_type MANUAL
                    }
                    -ftp_proxy {
                        set ftp_proxy $option_value
                        set proxy_type MANUAL
                    }
                    -ssl_proxy {
                        set ssl_proxy $option_value
                        set proxy_type MANUAL
                    }
                    -socks_proxy {
                        set socks_proxy $option_value
                        set proxy_type MANUAL
                    }
                    -socks_username {
                        set socks_username $option_value
                        set proxy_type MANUAL
                    }
                    -socks_password {
                        set socks_password $option_value
                        set proxy_type MANUAL
                    }
                    -capabilities {
						set desired_capabilities $option_value
					}
                    -7z {
                        set 7z $option_value
                    }
                    default {
						return -code error "Invalid option: $option_name"
					}
                }
            }

            if {![info exists desired_capabilities]} { 
				set desired_capabilities [::selenium::desired_capabilities FIREFOX]
                if {[info exists path_to_geckodriver]} {
                    dict set desired_capabilities marionette true
                }
			}
            
            set required_capabilities [dict create]

            if {[info exists path_to_browser_binary]} {
                dict set desired_capabilities moz:firefoxOptions binary $path_to_browser_binary
            } else {
                set path_to_browser_binary [::browser_info::firefox get_path]
                if {$path_to_browser_binary eq ""} {
                    # couldn't find firefox on the system
                    throw $Exception(WebdriverException) "Could not find firefox in your system. Please specify the firefox binary location or install firefox"
                }
			}
            
            if {$profile_directory ne ""} {
                # TODO create base64 of zip file of profile directory
                # and add to capabilities
                dict set desired_capabilities moz:firefoxOptions profile $zipped_profile
            }
            
            if {[info exists browser_arguments]} {
                dict set desired_capabilities args moz:firefoxOptions $browser_arguments
            }
            
            set proxy [dict create]
            
            if {[info exists proxy_type]} {
                dict set proxy proxyType $proxy_type
            }
            
            if {[info exists http_proxy]} {
                lassign [split $http_proxy :] host port

                dict set proxy httpProxy $host
                dict set proxy httpProxyPort $port
            }
            
            if {[info exists ftp_proxy]} {
                dict set proxy ftpProxy $ftp_proxy
            }
            
            if {[info exists ssl_proxy]} {
                dict set proxy sslProxy $ssl_proxy
            }
            
            if {[info exists autodetect_proxy]} {
                dict set proxy autodetect $autodetect_proxy
            }
            
            if {[info exists socks_proxy]} {
                dict set proxy socksProxy $socks_proxy
            }
            
            if {[info exists socks_username]} {
                dict set proxy socksUsername $socks_username
            }
            
            if {[info exists socks_password]} {
                dict set proxy socksPassword $socks_password
            }
            
            if {![info exists port]} {
                set port [get_free_port]
            }
            
            if {![info exists use_geckodriver]} {
                if {[::browser_info::firefox get_version] < 47.0} {
                    set use_geckodriver 0
                } else {
                    set use_geckodriver 1
                }
            }

            if {$use_geckodriver} {
                if {[dict size $proxy] != 0} {
                    # There is a bug. Proxy settings in required capabilities
                    #    https://github.com/mozilla/geckodriver/issues/97
                    dict set required_capabilities proxy $proxy
                }

                dict set desired_capabilities marionette 1

                if {![info exists path_to_geckodriver]} {
                    if {$::tcl_platform(platform) eq "windows"} {
                        set path_to_geckodriver geckodriver.exe
                    } else {
                        set path_to_geckodriver geckodriver
                    }
                }
            } else {
                if {[dict size $proxy] != 0} {
                    dict set desired_capabilities proxy $proxy
                }
                
                if {![info exists 7z]} {
                    if {[catch {exec 7za}]} {
                        if {[catch {exec 7z}]} {
                            return -code error "7z not found"
                        } else {
                            set 7z 7z
                        }
                    } else {
                        set 7z 7za
                    }
                }

                if {![info exists path_to_log_file]} {
                    if {$::tcl_platform(platform) eq "windows"} {
                        set path_to_log_file NUL
                    } elseif {$::tcl_platform(os) eq "Linux"} {
                        set path_to_log_file /dev/null
                    } elseif {$::tcl_platform(os) eq "MacOS" || $::tcl_platform(os) eq "Darwin"} {
                        set path_to_log_file Dev:Null
                    } else {
                        throw $Exception(WebDriver) "Not supported operating system"
                    }
                }
            }
            

            next [my service_url] $desired_capabilities $required_capabilities
		}
                
        method service_url {} {
            if {[::browser_info::firefox get_version] < 47.0} {
                return "http://127.0.0.1:$port/hub"
            } else {
                return "http://127.0.0.1:$port"
            }
		}
                
        method stop_client {} {
            kill $pid
            
            if {$use_geckodriver} {
                close $log_filehandler
                $profile uninstall_profile
            }
        }
        
        method firefox_profile {} {
            return $profile
        }
    
        method connect_and_quit {} {
            # Connects to an running browser and quit immediately.
            ::http::geturl "[my service_url]/extensions/firefox/quit"
        }
    
        method start_client {} {
                        
            if {$use_geckodriver} {
                my _start_client_with_geckodriver
            } else {
                my _start_client_installing_extension
            }
        }
        
        method _start_client_with_geckodriver {} {
            set parameters [list --port=$port -b $path_to_browser_binary]

            if {[info exists path_to_log_file]} {
                lappend parameters --log-file=\"$path_to_log_file\"
            }
            
            if { [catch {set pid [exec $path_to_geckodriver {*}$parameters &]}] } {
				error {geckodriver executable should be provided or be in the path.\
				Please download the latest version from http://github.com/mozilla/geckodriver/releases}
			}
            
            if {![my wait_until_connectable $port]} {
                error "Can not connect to the FirefoxDriver"
            }
            
        }
        
        method _start_client_installing_extension {} {
            # Firefox ships with an open-source crash reporting system. This system is combination
            # of projects:
            #   - Google Breakpad client and server libraries
            #   - Mozilla-specific crash reporting user interface and bootstrap code
            #   - Socorro Collection and reporting server
            #
            # Google breakpad is an open-source multi-platform crash reporting system
            #
            # This environment variable disable Breakpad crash reporting completely.

            package require selenium::firefox::profile

            set profile [::selenium::webdrivers::firefox::Firefox_Profile new $7z $profile_directory]

            $profile set_port $port
            $profile install_profile
                
            set _firefox_env(MOZ_CRASHREPORTER_DISABLE) 1
            
            # This environment variable makes the same functionality than the -no-remote switch 
            # of the firefox binary
            set _firefox_env(MOZ_NO_REMOTE) 1
            
            # The MOZ_NO_REMOTE environment variable allows you to run an instance of Firefox 
            # separately from any other instances of Firefox you have running. The NO_EM_RESTART
            # environment variable keeps Firefox attached to the terminal window after it starts 
            # and allows the browser to be terminated by typing Control-C in Firefox's terminal 
            # window.
            set _firefox_env(NO_EM_RESTART) 1

            
            # Launches the browser for the given profile path. It is assumed the profile already 
            # exists.
            set _firefox_env(XRE_PROFILE_PATH) [$profile path_of_installation profile]

            if {$::tcl_platform(os) eq "Linux"} {
                # The no focus library is a external dynamic library for linux and needed for the
                # firefox extension. This library tries to trick the X Window system in this way: 
                #           When a FocusOut detected it is replaced by another XEvent.
                
                set built_paths_to_no_focus_libs [$profile path_of_installation noFocusLibs]
                
                # The environment variable LD_LIBRARY_PATH list directories where the system 
                # searches for runtime libraries in addition to those hard-defined by ld and 
                # in /etc/ld.so.conf.d/*.conf files.
                if {[info exists ::env(LD_LIBRARY_PATH)]} {
                    set _firefox_env(LD_LIBRARY_PATH) "[join $built_paths_to_no_focus_libs :]:${::env(LD_LIBRARY_PATH)}"
                } else {
                    set _firefox_env(LD_LIBRARY_PATH) "[join $built_paths_to_no_focus_libs :]"
                }
            
                # Ordinarily the dynamic linker loads shared libs in whatever order it needs them
                # $LD_PRELOAD is an denvironment variable containing a colon (or space) separated 
                # list of libraries that the dynamic linker loads before any others. 
                #
                # Entries containing "/" are treated as filenames. 
                # Entries not containing "/" are searched for as usual
                #
                # Preloading a library means that its functions will be used before others of the
                # same name in later libraries
                #   - Allows functions to be overridden/replaced/intercepted
                #   - Program behaviour can be modified "non-invasively" ie. no 
                # recompile/relink necessary
                #   - Especially useful for closed-source programs
                #   - And when the modifications don’t belong in the program or the library

                set _firefox_env(LD_PRELOAD) [$profile no_focus_library_name]
            }
                        
            array set cached_env [array get ::env]
            array set ::env [array get _firefox_env]

            set log_filehandler [open $path_to_log_file "wb"]
            catch {exec $path_to_browser_binary -foreground >@$log_filehandler &} pid
            
            if {![my wait_until_connectable $port]} {
                error "Can not connect to the FirefoxDriver"
            }
            
            # restart environment variables
            array unset ::env
            array set ::env [array get cached_env]     
        }
	}
}

namespace eval ::selenium {
	namespace import ::selenium::webdrivers::firefox::FirefoxDriver
	namespace export FirefoxDriver
}
