package provide selenium::utils::process 0.1

namespace eval ::selenium::utils::process {
    namespace export *
    
	proc kill {pid} {
		if {$::tcl_platform(platform) eq "windows"} {
			if {[catch {package require twapi}]} {
                exec {*}[auto_execok taskkill.exe] /F /PID $pid			
			} else {
				catch {twapi::end_process $pid -force}
			}
		} else {
			exec kill -SIGKILL $pid	
		}
	}
    
    proc find_executable {executable} {
        foreach path [split $::env(PATH) $tcl_platform(pathSeparator)] {
            set exe [file join $path $executable]
            if {[file isfile $exe] && [file executable $exe]} {
                return $exe
            }
        }

        return {}
    }
    
    proc process_exists {pid} {
        if {$::tcl_platform(platform) eq "windows"} {
            set tasklist [exec {*}[auto_execok tasklist.exe] /FO TABLE /NH]
            return [regexp -lineanchor "^\\s*\\S+\\s+$pid\\s" $tasklist]
        } else {
            if {[catch { set fp [open "/proc/$pid/stat"]}] != 0} {
                return 0
            }

            set stats [read $fp]
            close $fp

            if {[regexp {\d+ \([^)]+\) (\S+)} $stats match state]} {
                if {$state eq {Z}} {
                    return 0
                }
            }

            return 1
        }
    }
}
