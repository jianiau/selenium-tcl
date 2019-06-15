package provide selenium::utils::tempdir 0.1

namespace eval ::selenium::utils::tempdir {
    namespace export *
    
    variable TMP_MAX 10000
    variable tempdir_prefix "tmp"


    proc native_tempdir {} {
        global tcl_platform env

        set attempdirs [list]
        set problems [list]
        
        switch $tcl_platform(platform) {
            windows {
                if { [info exists env(TEMP)] } {
                    lappend attempdirs $env(TEMP)
                } else {
                    lappend problems "No environment variable TEMP"
                }
                
                if { [info exists env(TMP)] } {
                    lappend attempdirs $env(TMP)
                } else {
                    lappend problems "No environment variable TMP"
                }
                
                if { [info exists env(SystemRoot)] } {
                    lappend attempdirs "$env(SystemRoot)\\temp"
                }
                
                if { [info exists env(windir)] } {
                    lappend attempdirs "$env(windir)\\temp"
                }
                
                lappend attempdirs "C:\\TEMP" "C:\\TMP" "\\TEMP" "\\TMP"
            }
            macintosh {
                lappend attempdirs $env(TRASH_FOLDER)  ;# a better place?
            }
            default {
                if { [info exists env(TMPDIR)] } {
                    lappend attempdirs $env(TMPDIR)
                } else {
                    lappend problems "No environment variable TMPDIR"
                }
                
                if { [info exists env(TMP)] } {
                    lappend attempdirs $env(TMP)
                } else {
                    lappend problems "No environment variable TMP"
                }
                
                if { [info exists env(TEMP)] } {
                    lappend attempdirs $env(TEMP)
                } else {
                    lappend problems "No environment variable TEMP"
                }
                
                lappend attempdirs \
                    [file join / tmp] \
                    [file join / var tmp] \
                    [file join / usr tmp]
            }
        }

        lappend attempdirs [pwd]

        foreach tmp $attempdirs {
            if { [file isdirectory $tmp] && [file writable $tmp] } {
                return $tmp
            } elseif { ![file isdirectory $tmp] } {
                lappend problems "Not a directory: $tmp"
            } else {
                lappend problems "Not writable: $tmp"
            }
        }

        # Fail if nothing worked.
        return -code error "Unable to determine a proper directory for temporary files\n[join $problems \n]"
    }
    
    
    proc create_tempdir {args} {        
        variable TMP_MAX
        variable tempdir_prefix
        
		global tcl_platform
		set platform $tcl_platform(platform)
		
        array set options [list -suffix "" -prefix $tempdir_prefix -dir "" {*}$args]
        puts $options(-suffix)
        
        if {$options(-dir) eq ""} {
            #package require fileutil
            #set options(-dir) [::fileutil::tempdir]
            set options(-dir) [native_tempdir]
        }
        
        set chars abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789
        for {set i 0} {$i < $TMP_MAX} {incr i} {
            
            set directory_name $options(-prefix)
            for {set j 0} {$j < 10} {incr j} {
                append directory_name [string index $chars [expr {int(rand() * 62)}]]
            }
            append directory_name $options(-suffix)
            
            set path [file join $options(-dir) $directory_name]
            
            if {![file exists $path]} {

				if {![catch {file mkdir $path}]} {
					if {$platform eq "windows"} {
						return $path
					} else {
						if {![catch {file attributes $path -permissions 0700}]} {
							return $path
						} else {
							catch {file delete -force -- $path}
						}
					}
				}
            }
        }
        error "failed to find an unused temporary directory name"
    }
    
}
