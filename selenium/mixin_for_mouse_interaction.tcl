namespace eval ::selenium {    

	oo::class create Mixin_For_Mouse_Interaction {
        variable Mouse_Button Command

        method double_click {} {
            # Make double click

            my execute $Command(DOUBLE_CLICK)
        }
        
		method click {{element_ID ""}} {
			# Make a click if no element ID is guiven or click an specific element otherwise.
            
            if {$element_ID eq ""} {
                my execute $Command(CLICK)
            } else {
                
                my execute $Command(CLICK_ELEMENT) id $element_ID
            }
		}
        
        method click_and_hold {{element_ID ""}} {
            # Holds down the left mouse button on an element.
            # :Args:
            # - element_ID (OPTINAL): The element to mouse down.
            
            if {$element_ID ne ""} {
                my move_mouse_to_element $element_ID
            }
            
            my mouse_down RIGHT
        }
        
        method move_mouse {xoffset yoffset} {
            # Moving the mouse to an offset from current mouse position.

            my execute $Command(MOVE_TO) xoffset $xoffset yoffset $yoffset
        }
        
        method move_mouse_to_element {element_ID {xoffset {}} {yoffset {}}} {
            # Moving the mouse to the middle of an element, possibly adding some offsets
            
            if {($xoffset ne "") && ($yoffset ne "")} {
                my execute $Command(MOVE_TO) xoffset $xoffset yoffset $yoffset element $element_ID
            } else {
                my execute $Command(MOVE_TO) element $element_ID
            }
        }
        
        method mouse_down {buttonName} {
            # mouse down
            
            my execute $Command(MOUSE_DOWN) button $Mouse_Button($buttonName)
        }
        
        method mouse_up {buttonName} {
            # mouse up

            my execute $Command(MOUSE_UP) button $Mouse_Button($buttonName)
        }
        
    }
    
}
