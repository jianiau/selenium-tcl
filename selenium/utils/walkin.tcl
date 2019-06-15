package provide selenium::utils::walkin 0.1

namespace eval ::selenium::utils::walkin {
    namespace export walkin
    
    variable BREADTH_FIRST 0
    variable DEPTH_FIRST 1
    
    proc fullnormalize {path} {
        # from fileutil::fullnormalize in tcllib
        return [file dirname [file normalize $path/__dummy__]]
    }
    
    proc walkin {list_of_varnames root_path body {strategy 0} {follow_links 0}} {
        # list_of_varnames = subpath, dirs, files
        variable BREADTH_FIRST 
        variable DEPTH_FIRST  
        
        set search_list [list]
        
        foreach otherVar $list_of_varnames myVar [list parent_subpath dirs files] {
            upvar $otherVar $myVar
        }
        
        set base_path [fullnormalize $root_path]
        set parent_subpath {}
        
        while 1 {    
            set dirs [list]
            set files [list]
            
            set children [concat \
                    [glob -nocomplain -directory $base_path -types hidden *] \
                    [glob -nocomplain -directory $base_path *]]
        
        
            foreach child $children[set children {}] {
                set file_name [file tail $child]
                
                if {!($file_name eq "." || $file_name eq "..")} {
                    if {[file isdirectory $child]} {
                        set new_subpath [file join $parent_subpath $file_name]
                        if {$follow_links} {
                            if {[file type $child] eq "link"} {
                                lappend search_list [fullnormalize $new_subpath]
                            } else {
                                lappend search_list $new_subpath
                            }    
                        } else {
                            if {[file type $child] ne "link"} {
                                lappend search_list $new_subpath
                            }
                        }
                        
                        lappend dirs $file_name
                    } else {
                        lappend files $file_name
                    }
                }
            }
                        
            uplevel $body
            
            if {[llength $search_list] ==0} break
            
            if {$strategy == $BREADTH_FIRST} {
                set parent_subpath [lindex $search_list 0]
                set search_list [lreplace $search_list[set search_list ""] 0 0]
            
            } else {
                set parent_subpath [lindex $search_list end]
                set search_list [lreplace $search_list[set search_list ""] end end]
            }
            
            set base_path [file join $root_path $parent_subpath]        
        }
    }
}

