package provide selenium::firefox::manifest 0.2

package require tdom

namespace eval ::selenium::webdrivers::firefox {

    oo::class create ExtensionManifest {
        variable ManifestFormatError AddonIOerror 7z
        
        constructor {path_to_7z} {
            set ManifestFormatError {SELENIUM FIREFOX ManifestFormatError {Exception for not well-formed add-on manifest files}}
            set AddonIOerror {SELENIUM FIREFOX AddonIOerror}
            
            set 7z $path_to_7z
        }

        method get_namespace_id {doc url} {
            set found 0

            set attribute_list [$doc attributes xmlns*] 

            foreach attribute $attribute_list {                
                set namespace [lindex $attribute 1]
                
                if {$namespace eq ""} {
                    set attribute_name "xmlns"
                } else {
                    set attribute_name "xmlns:$namespace"
                }
                set attribute_value [$doc getAttribute $attribute_name]
                
                if {$attribute_value eq $url} {
                    set found 1
                    break
                }
            }
        
            if $found {
                return $namespace
            } else {
                return ""
            }

        }

        method get_text_of_element {element} {
            # Retrieve the text value of a given node
            set rc [list]
            foreach node [$element childNodes] {
                if {[$node nodeType] == "TEXT_NODE"} {
                    lappend rc [$node nodeValue]
                }
            }
        
            return [join [string trim $rc] "" ]
        }
        
        method addon_details {addon_path} {
            # Returns a dictionary of details about the addon.
            # 
            # :param addon_path: path to the add-on directory or XPI
            # 
            # Returns::
            # 
            # {'id':      u'rainbow@colors.org', # id of the addon
            # 'version': u'1.4',                # version of the addon
            # 'name':    u'Rainbow',            # name of the addon
            # 'unpack':  False }                # whether to unpack the addon
    

            set addon_details [dict set id "" unpack false name "" version ""]
    
            if {![file exists $addon_path]} {
                error "Add-on path does not exist: '$addon_path'"
            }
            
            set install_rdf [my read_manifest $addon_path]
            puts $install_rdf
            try {
                set doc [::dom::parse $install_rdf]
    
                # Get the namespaces abbreviations
                set em [get_namespace_id $doc http://www.mozilla.org/2004/em-rdf#]
                set rdf [get_namespace_id $doc http://www.w3.org/1999/02/22-rdf-syntax-ns#]
    
                set description [lindex [::dom::document getElementsByTagName $doc ${rdf}Description] 0]
                foreach node [dom::node children $description] {
                    # Remove the namespace prefix from the tag for comparison
                    set nodeName [dom::node cget $node -nodeName]
                    if {[string match ${em}* $nodeName]} {
                        set entry [string range $nodeName [string length $em] end]
                    } else {
                        set entry $nodeName
                    }
                    
                    if {[$entry in [dict keys $addon_details]} {
                        dict set addon_details $entry [get_text_of_element $node]
                    }
                }
                
                if {[dict get $addon_details id] == ""} {
                    set attributes [dom::node cget $description -attributes]
                    
                    foreach {attribute_name attribute_value} $attributes {
                        if {$attribute_name == "${em}id"} {
                            dict set addon_details id attribute_value
                        }
                    }
                }
            } on error {error_message} {
                throw $ManifestFormatError $error_message
            }
            
            # turn unpack into a true/false value
            dict set addon_details unpack [string lower [dict get $addon_details unpack]]
            
            # If no ID is set, the add-on is invalid
            if {[dict get $addon_details id] eq ""} {
                throw $ManifestFormatError {Add-on id could not be found.}
            }
    
            return $addon_details
        }
        
        method read_manifest {addon_path} {            
            if {[catch [list exec $7z t $addon_path]]} {
                
                if {[file isdirectory $addon_path]} {
                    set channeldId [open [file join $addon_path install.rdf] r]
                    set install_rdf [read $channeldId]
                } else {
                    throw $AddonIOerror "Add-on path is neither an XPI nor a directory: '$addon_path'"
                }
            } else {
                try {
                    set pipe [open [list | $7z e -so $addon_path install.rdf]]
                    set install_rdf [read $pipe]
                    catch {close $pipe}
                    #set compressed_file [::zipfile::decode::open $addon_path]
                    #set install_rdf [::zipfile::decode::getfile [::zipfile::decode::archive] install.rdf]
                } on error {errorMsg} {
                    #::zipfile::decode::close
                    throw $AddonIOerror "Error decoding the zip file '$addon_path': $errorMsg"
                }
                
            }
            
            return $install_rdf
        }
    
        method addon_details {addon_path} {
            # Returns a dictionary of details about the addon.
            # 
            # :param addon_path: path to the add-on directory or XPI
            # 
            # Returns::
            # 
            # {id      rainbow@colors.org # id of the addon
            #  version 1.4                # version of the addon
            #  name    Rainbow            # name of the addon
            #  unpack  false }            # whether to unpack the addon
    

            set addon_details [dict create id "" unpack false name "" version ""]
    
            if {![file exists $addon_path]} {
                error "Add-on path does not exist: '$addon_path'"
            }
            
            set install_rdf [my read_manifest $addon_path]
            
            try {
                set dom [::dom parse $install_rdf]
                set doc [$dom documentElement]

                # Get the namespaces abbreviations
                set em [my get_namespace_id $doc http://www.mozilla.org/2004/em-rdf#]
                set rdf [my get_namespace_id $doc http://www.w3.org/1999/02/22-rdf-syntax-ns#]
                
                set description_nodes [$doc getElementsByTagName ${rdf}Description]
                
                if {[llength $description_nodes]==0} {
                    set description_nodes [$doc getElementsByTagName Description]
                }
                
                set manifest_description [lindex $description_nodes 0]

                foreach node [$manifest_description childNodes] {
                    # Remove the namespace prefix from the tag for comparison
                    set nodeName [$node nodeName]
                    if {[string match ${em}* $nodeName]} {
                        set entry [string range $nodeName [expr [string length $em]+1] end]
                    } else {
                        set entry $nodeName
                    }

                    if {$entry in [dict keys $addon_details]} {
                        dict set addon_details $entry [my get_text_of_element $node]
                    }
                }
                
                if {[dict get $addon_details id] == ""} {

                    foreach attribute_name [$manifest_description attributes] {
                        if {$attribute_name == "${em}id"} {
                            dict set addon_details id [$manifest_description getAttribute $attribute_name]
                        }
                    }
                }
            } on error {error_message} {
                throw $ManifestFormatError $error_message
            }
            
            # turn unpack into a true/false value
            dict set addon_details unpack [string tolower [dict get $addon_details unpack]]
            
            # If no ID is set, the add-on is invalid
            if {[dict get $addon_details id] eq ""} {
                throw $ManifestFormatError {Add-on id could not be found.}
            }
    
            return $addon_details
        }

    }     
    
    #puts [[ExtensionManifest new] addon_details webdriver.xpi]
}
