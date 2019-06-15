namespace eval ::selenium::container_of_webelements {
	namespace export Container_Of_WebElements
    
	oo::class create Container_Of_WebElements {
		variable driver list_of_element_IDs set_of_webelements container_length
		
		constructor {theDriver listOfElementIds} {
            namespace import ::selenium::webelement::WebElement
			            
			set driver $theDriver
			
            set list_of_element_IDs $listOfElementIds
            
            set container_length [llength $listOfElementIds]
            array set set_of_webelements ""
		}
        
        method list_of_element_IDs {} {
            return $list_of_element_IDs
        }
		        
		method index {i} {
            if {$i >= 0 && $i < [llength $list_of_element_IDs]} {
                if {[info exists set_of_webelements($i)]} {
                    set webelement $set_of_webelements($i)
                } else {
                    set webelement [WebElement new $driver [lindex $list_of_element_IDs $i]]
                    set set_of_webelements($i) $webelement
                }
                
                return $webelement
            } else {
                return ""
            }
		}
		
		method length {} {
			return $container_length
		}
        
        method foreach {elementVar codeToEval} {
            upvar $elementVar webelement
            set return_code [catch {
                for {set i 0} {$i < $container_length} {incr i} {
                    set webelement [my index $i]
                    uplevel $codeToEval
                }
            } return_message]
            
            return -code $return_code $return_message
        }
			
		destructor {
			foreach webelement [dict values $set_of_webelements] {
				catch "$webelement destroy"
			}
		}
		
	}
}
