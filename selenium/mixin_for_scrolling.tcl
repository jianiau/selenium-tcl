namespace eval ::selenium {
    
	oo::class create Mixin_For_Scrolling {

        method scroll_into_view {element} {
            # Scroll element into view

            my execute_javascript {arguments[0].scrollIntoView(false);} -arguments [list element $element]
        }
        
        method scroll_to_bottom {} {
            # scroll to bottom of webpage

            my execute_javascript {window.scrollTo(0,Math.max(document.documentElement.scrollHeight, document.body.scrollHeight, document.documentElement.clientHeight));}
        }
        
        method scrolling_position {} {
            # Get the scrolling position

            return [my execute_javascript { 
                var x = 0, y = 0;
                if( typeof( window.pageYOffset ) == 'number' ) {
                    // Netscape
                    x = window.pageXOffset;
                    y = window.pageYOffset;
                } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
                    // DOM
                    x = document.body.scrollLeft;
                    y = document.body.scrollTop;
                } else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
                    // IE6 standards compliant mode
                    x = document.documentElement.scrollLeft;
                    y = document.documentElement.scrollTop;
                }
                
                return [x, y];
            }]
        }  
        
        method scroll_to_bottom_infinitely {{condition_command ""} {timeout 5000}} {
            # scroll to bottom until condition provided is true or it's not possible to scroll more

            set scroll_Y_position [lindex [my scrolling_position] 1]
            
            while 1 {
                my scroll_to_bottom
                after $timeout
                
                set last_scroll_Y_position $scroll_Y_position
                
                set scroll_Y_position [lindex [my scrolling_position] 1]
                
                if {$last_scroll_Y_position == $scroll_Y_position || ($condition_command ne "" && [{*}$condition_command])} break
            }

        }
        
    }
    
}    
