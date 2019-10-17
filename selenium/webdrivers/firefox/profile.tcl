package provide selenium::firefox::profile 0.2

package require selenium::firefox::manifest

package require selenium::utils::types
package require selenium::utils::types::json

package require selenium::utils::walkin
package require selenium::utils::tempdir
package require selenium::utils::base64

namespace eval ::selenium::webdrivers::firefox {
    namespace import ::selenium::Exception
    
    oo::class create Firefox_Profile {
    
        variable CURRENT_DIR DEFAULT_PREFERENCES NO_FOCUS_LIBRARY_NAME SELENIUM_ADDON NATIVE_EVENTS_SUPPORTED manifest provided_profile_directory installation_path list_of_user_extensions user_preferences is_profile_installed 7z
        constructor {7z_binary {profileDirectory ""}} {
            # Initialises a new instance of a Firefox Profile
            # 
            # :args:
            # - provided_profile_directory: Directory of profile that you want to use.
            # This defaults to "" and will create a new
            # directory when object is created.

            set CURRENT_DIR [file dirname [ dict get [ info frame [ info frame ] ] file ]]

            # Synchronously loads the default preferences used for the FirefoxDriver.
            set fh [open [file join $CURRENT_DIR webdriver_prefs.json]]
            set DEFAULT_PREFERENCES [::types::parse_json [read $fh]]
            close $fh
    
            # There is no native event support on Mac
            if {$::tcl_platform(os) eq "MacOS" || $::tcl_platform(os) eq "Darwin"} {
                set NATIVE_EVENTS_SUPPORTED false
            } else {
                set NATIVE_EVENTS_SUPPORTED true
            }
    
            set SELENIUM_ADDON [file join $CURRENT_DIR webdriver.xpi]
    
            set NO_FOCUS_LIBRARY_NAME x_ignore_nofocus.so
            
            set 7z $7z_binary
            set manifest [::selenium::webdrivers::firefox::ExtensionManifest new $7z_binary]

            set user_preferences [$DEFAULT_PREFERENCES get mutable]
            set provided_profile_directory $profileDirectory
            set list_of_user_extensions [list]
            set is_profile_installed 0
            
            if {$NATIVE_EVENTS_SUPPORTED} {
                my set_native_events_enabled true
            } else {
                my set_native_events_enabled false
            }
        }
        
        method no_focus_library_name {} {
            return $NO_FOCUS_LIBRARY_NAME
        }
        
        method path_of_installation {{component profile}} {
            # Gets the profile directory that is currently being used
            if {$is_profile_installed} {
                return $installation_path($component)
            } else {
                throw $Exception(WebDriver) "The profile has not been installed yet"
            }
        }
        
        method get_port {} {
            # Gets the port that WebDriver is working on
            return $port
        }
        
        method set_port {port_number} {
            # Sets the port that WebDriver will be running on
    
            if {![string is digit $port_number]} {
                throw $Exception(WebDriver) {Port needs to be an integer}
            }
            
            if {$port_number < 1 || $port_number > 65535} {
                throw $Exception(WebDriver) {Port number must be in the range 1..65535}
            }
    
            set port $port_number
            
            my set_preference webdriver_firefox_port $port_number number
        }
        
        method set_preference {property value type} {
            # sets the preference that we want in the profile.
            # value should be a typed object
            
            if {$type eq "string"} {
                set obj [::types::String new $value]
            } elseif {$type eq "boolean"} {
                set obj [::types::Boolean new $value]
            } elseif {$type eq "number"} {
                set obj [::types::Number new $value]
            } else {
                throw $Exception(WebDriver) "Invalid type: $type"
            }
            
            $user_preferences set $property $obj
        }
        
        method get_preference {property} {
            return [[$user_preferences get $property] strip]
        }
                       
        method accept_untrusted_certs {{stripped true}} {
            return [my get_preference webdriver_accept_untrusted_certs $stripped]
        }

        method set_accept_untrusted_certs {value} {
            if {!($value eq "true" || $value eq "false")} {
                throw $Exception(WebDriver) "Please pass in a Boolean to this call"
            }
            
            my set_preference webdriver_accept_untrusted_certs $value
        }
        
        method assume_untrusted_cert_issuer {} {
            return [my get_preference webdriver_assume_untrusted_issuer]
        }
        
        method set_assume_untrusted_cert_issuer {value} {
            if {!($value eq "true" || $value eq "false")} {
                throw $Exception(WebDriver) {Please pass in a Boolean to this call}
            }
            
            my set_preference webdriver_assume_untrusted_issuer $value boolean
        }
        
        method native_events_enabled {} {
            return [my get_preference webdriver_enable_native_events]
        }
        
        method set_native_events_enabled {value} {
            if {!($value eq "true" || $value eq "false")} {
                throw $Exception(WebDriver) {Please pass in a Boolean to this call}
            }
            
            if {!$NATIVE_EVENTS_SUPPORTED && $value eq "true"} {
                throw $Exception(WebDriver) {Native events are not allowed}
            }
            
            my set_preference webdriver_enable_native_events $value boolean
        }
        
        method are_native_events_supported {} {
            return $NATIVE_EVENTS_SUPPORTED
        }
        
        method encoded {} {
            # A zipped, base64 encoded string of profile directory
            # for use with remote WebDriver JSON wire protocol
            
            if {![file exists ${installation_path(profile)}.zip]} {
                exec $7z a -r $installation_path(profile) -o$installation_path(tempFolder)
            }
            set fh [open ${installation_path(profile)}.zip]
            set zipContent [read $fh]
            
            close $fh
            return [::base64::encode $zipContent]
        }

        method _install_user_prefs {path_of_installation} {
            # Update the user preferences with the frozen preferences and
            # writes the guiven preferences to the installation path
            
            [$DEFAULT_PREFERENCES get frozen] for {key value} {
                $user_preferences set $key $value
            }
    
            set fileId [open [file join $path_of_installation user.js] w]
            $user_preferences for {key value} {
                puts $fileId "user_pref(\"$key\", [$value to_json]);"
            }
            close $fileId
        }
    
        method _update_preferences_from_userjs_file {path_to_userjs} {
            set PREF_RE {user_pref\("(.*)",\s(.*)\)}
            
            if {![catch [set fp [open $path_to_userjs r]]]} {
                set file_data [read $fp]
                foreach usr [split $file_data "\n"] {
                    regexp $PREF_RE $usr -> preference_name preference_value

                    my set_preference $preference_name [::types::parse_json $preference_value]
                }
                
                close $fp
            } 
        }
        
        method add_addon {addon {unpack true}} {
            lappend list_of_user_extensions [list $addon $unpack]
        }
        
        method _install_selenium_addon {path_of_installation} {
            my _install_addon $path_of_installation $SELENIUM_ADDON
        }
        
        method _install_addon {path_of_installation addon {unpack true}} {
            # Installs addon from a filepath, url
            # or directory of addons in the profile.
            # - path: url, path to .xpi, or directory of addons
            # - unpack: whether to unpack unless specified otherwise in the install.rdf
    
            # determine the addon id
            set addon_details [$manifest addon_details $addon]
            set addon_id [dict get $addon_details id]
            
            if {$addon_id eq ""} {error "The addon id could not be found"}
                
            set path_to_installed_addon [file join $path_of_installation $addon_id]
            
            
            if {[string match "*.xpi" $addon]} {                               
                if {!$unpack && ![dict get $addon_details unpack]} {
                    file mkdir $extensions_path
                    append path_to_installed_addon .xpi
                
                    file copy $addon $path_to_installed_addon
                } else {
                    exec $7z x $addon -o$path_to_installed_addon
                }
                
            } else {
                file copy $addon $path_to_installed_addon
            }
        }
        
        method _install_addons {path_of_installation} {
            set extensions_directory [file join $path_of_installation extensions]
            file mkdir $extensions_directory
            
            foreach {user_addon unpack_flag} $list_of_user_extensions {
                my _install_addon $extensions_directory $user_addon $unpack_flag
            }
            
            my _install_selenium_addon $extensions_directory
        }
        
        method _install_no_focus_libs {path_of_installation} {
            set path_to_installed_libs [list]
            foreach architecture_name {x86 amd64} {
                set lib_path [file join $path_of_installation $architecture_name]
                
                file mkdir $lib_path
                
                file copy [file join $CURRENT_DIR $architecture_name $NO_FOCUS_LIBRARY_NAME] $lib_path
                
                lappend path_to_installed_libs $lib_path
            }
            
            return $path_to_installed_libs
    
        }
        
        method is_profile_installed {} {
            return $is_profile_installed
        }
        
        method uninstall_profile {} {
            if {$is_profile_installed} {
                file delete -force $installation_path(tempFolder)
                set is_profile_installed 0
            }      
        }
        
        method install_profile {} {
            
            array set installation_path {}
            
            set installation_path(tempFolder) [::selenium::utils::tempdir::create_tempdir -prefix selenium_]
            file mkdir $installation_path(tempFolder)
            
            set installation_path(profile) [file join $installation_path(tempFolder) webdriver-tcl-profilecopy]
            file mkdir $installation_path(profile)

            if {$provided_profile_directory ne ""} {              
                ::selenium::utils::walkin::walkin {parent_path files dirs} $provided_profile_directory {
                    foreach file_name $files {
                        if {$file_name ne "parent.lock" && $file_name ne "lock" && $file_name ne ".parentlock"} {
                            file copy  [file join $provided_profile_directory $parent_path $file_name] [file join $installation_path(profile) $parent_path $file_name]
                        }
                    }
                }
                
                my _update_preferences_from_userjs_file [file join $installation_path(profile) user.js]
            }           
            
            if {$::tcl_platform(os) eq "Linux"} {
                set installation_path(noFocusLibs) [my _install_no_focus_libs $installation_path(profile)]
            }

            my _install_user_prefs $installation_path(profile)
            my _install_addons $installation_path(profile)
            
            set is_profile_installed 1
        }
        
        destructor {
            $DEFAULT_PREFERENCES destroy
            my uninstall_profile
        }
    }
    
}
