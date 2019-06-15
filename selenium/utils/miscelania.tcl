namespace eval ::selenium::utils {
	namespace export *
	
    proc channel_join {channelId {timeout ""}} {
        if {$timeout ne ""} {
            set deadline [expr {[clock milliseconds] + $timeout}]
        } else {
            set deadline ""
        }
        
        set result 1
        while {![eof $channelId]} {
	        if {$deadline ne "" && $deadline > [clock milliseconds]} {
                return 0
            }

            after 100
        }
        chan configure $channelId -blocking 1
        catch {close $channelId}
        
        return 1
    }
}
	

	
