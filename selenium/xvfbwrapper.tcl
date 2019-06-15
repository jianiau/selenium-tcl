package provide xvfbwrapper 0.1

# wrapper for running display inside X virtual framebuffer (Xvfb)

# Example of usage:
#   set xvfb [::xvfb::Xvfb new -width 342 -height 234]
#   $xvfb start
#   ...do something here
#   $xvfb stop
#

namespace eval ::xvfb {
    namespace export Xvfb

    # Maximum value to use for a display. 32-bit maxint is the highest Xvfb currently supports
    variable MAX_DISPLAY 2147483647
    variable SLEEP_TIME_BEFORE_START 100
    
    variable TMPDIR [pwd]
    if {[file exists "/tmp"]} {set TMPDIR "/tmp"}
    catch {set TMPDIR $::env(TRASH_FOLDER)} ;# very old Macintosh. Mac OS X doesn't have this.
    catch {set TMPDIR $::env(TMP)}
    catch {set TMPDIR $::env(TEMP)}
    
    proc rand_range {min max} {
        return [expr int(rand()*($max-$min+1)) + $min]
    }
    
    set XVFB_ERROR {XVFB_ERROR {Error of xvfb module}}
    
    oo::class create Xvfb {
        variable extra_xvfb_args width height display colordepth tempdir Xvfb_PID orig_display lock_display_file

        constructor {args} {
            array set options {-width 800  -height 680 -colordepth 24}
            array set options $args

            set width $options(-width)
            set height $options(-height)
            set colordepth $options(-colordepth)
            
            if [info exists options(-display)] {
                set display $options(-display)
            } else {
                set display ""
            }
            
            if [info exists options(-tempdir)] {
                set tempdir $options(-tempdir)
            } else {
                set tempdir $::xvfb::TMPDIR
            }
            
            if {![my xvfb_exists]} {
                throw $::xvfb::XVFB_ERROR {Can not find Xvfb. Please install it and try again.}
            }
            
            set extra_xvfb_args [list -screen 0 ${width}x${height}x${colordepth}]
            
            if {[info exists options(-xvfb_args)]} {
                foreach {key value} $options(-xvfb_args) {
                    lappend extra_xvfb_args -$key $value
                }
            }

            if [info exists ::env(DISPLAY)] {
                set orig_display [lindex [split $::env(DISPLAY) :] 1]
            } else {
                set orig_display ""
            }
            
            set Xvfb_PID ""
        }
        
        method start {} {
            if {$display eq ""} {
                set new_display [my _get_next_unused_display]
            } else {
                set new_display $display
            }
            
            set Xvfb_PID [exec Xvfb :$new_display {*}$extra_xvfb_args  > /dev/null 2>@1 &]

            # give Xvfb time to start
            after $::xvfb::SLEEP_TIME_BEFORE_START
            
            if {[catch {exec ps $Xvfb_PID} std_out] == 0} { 
                my _set_display_var $new_display
            } else {
                puts $std_out
                my _cleanup_lock_file
                throw $::xvfb::XVFB_ERROR {Xvfb did not start}
            }
        }

        method stop {} {
            if {$orig_display eq ""} {
                unset ::env(DISPLAY)
            } else {
                my _set_display_var $orig_display
            }
            
            if {$Xvfb_PID ne ""} {
                exec kill -9 $Xvfb_PID
                set Xvfb_PID ""
            }
        
            my _cleanup_lock_file
        }

        method xvfb_exists {} {
            # Check that Xvfb is available on PATH and is executable.
            set paths [split $::env(PATH) $::tcl_platform(pathSeparator)]
            
            foreach path $paths {
                if {[file executable [file join $path Xvfb]]} {
                    return 1
                }
            }
            return 0
        }

        method _set_display_var {display} {
            set ::env(DISPLAY) :$display
        }
        
        method _cleanup_lock_file {} {
            # This should always get called if the process exits safely
            # with $xvfb stop.
            # If you are ending up with /tmp/Xvfb-lock files when Xvfb is not
            # running, then Xvfb is not exiting cleanly. Always either call
            # $xvfb stop in a finally block, or use Xvfb as a context manager
            # to ensure lock files are purged.

            file delete $lock_display_file
        }
        
        method _get_next_unused_display {} {
            #
            # In order to ensure multi-process safety, this method attempts
            # to acquire an exclusive lock on a temporary file whose name
            # contains the display number for Xvfb.

            set tempfile_path [file join $tempdir .Xvfb-lock]
            while 1 {
                set rand [::xvfb::rand_range 1 $::xvfb::MAX_DISPLAY]
                
                # https://groups.google.com/forum/#!topic/comp.lang.tcl/bjg8IZqmCk8
                set lock_display_file ${tempfile_path}$rand

                try {
                    close [open $lock_display_file {CREAT WRONLY EXCL}]
                    break
                } on error {} {}
            }

            return $rand
        }
    }

}

