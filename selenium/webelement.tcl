namespace eval ::selenium::webelement {
    namespace export WebElement
    
	oo::class create WebElement {
        variable driver element_ID Command Exception
        
        constructor {theDriver elementID} {
            namespace import ::selenium::Select_Element
            
            namespace eval [self] {
                namespace upvar ::selenium By By Command Command Exception Exception
            }
            
            
            set driver $theDriver
            set element_ID $elementID
        }
        
        method element_ID {} {
            return $element_ID
        }
                        
        method execute {args} {
            $driver execute {*}$args
        }
        
        method execute_and_get_value {args} {
            $driver execute_and_get_value {*}$args
        }
        
        method is_select_element {} {
            return [$driver is_select_element $element_ID]
        }
        
        method add_select_mixin {} {
            if {[my is_select_element]} {
                oo::objdefine [self] mixin ::selenium::Select_Element
                my Initialize_mixin
            } else {
                throw $Exception(UnexpectedTagName) "Select only works on <select> elements, not on $tag_name_of_element"
            }
            
        }
        
		method is_displayed {} {
			# Whether the element would be visible to a user
		
			return [$driver is_displayed $element_ID]
		}
		
		method tag_name {} {
			# Gets this element's tagName property.
		
			return [$driver tag_name $element_ID]
		}
		
	
		method get_visible_text {} {
			# Gets the visible text of the element.
		
			return [$driver get_visible_text $element_ID]
		}
		
		method get_text {} {
			# Gets the text of the element.
            return [$driver get_text $element_ID]
		}
		
		method click {} {
			# Clicks the element.
			$driver click $element_ID
		}
		
		method submit_form {} {
			# Submits a form.
		
			$driver submit_form $element_ID
		}
		
		method clear_text {} {
			# Clears the text if it's a text entry element.
		
			$driver clear_text $element_ID
		}
		
		method get_attribute {attribute_name} {
			# Gets the given attribute or property of the element.
			# 
			# This method will return the value of the given property if this is set,
			# otherwise it returns the value of the attribute with the same name if
			# that exists, or None.
			# 
			# :Args:
			# - name - Name of the attribute/property to retrieve.
			# 
			# Example::
			# 
			# # Check if the "active" CSS class is applied to an element.
			#	set class_attribute	[$driver get_element_attribute $target_element class]
			# 	set is_active [expr {[string first $class_attribute active]!=-1}]
		
			return [$driver get_attribute $element_ID $attribute_name]
		}
		
		method is_selected {} {
			# Whether the element is selected.
			# 
			# Can be used to check if a checkbox or radio button is selected.
		
			return [$driver is_selected $element_ID]
		}
		
		method is_enabled {} {
			# Whether the element is enabled.
		
			return [$driver is_enabled $element_ID]
		}
		
		method location_once_scrolled_into_view {} {
			# CONSIDERED LIABLE TO CHANGE WITHOUT WARNING. Use this to discover where on the screen an
			# element is so that we can click it. This method should cause the element to be scrolled
			# into view.
			# 
			# Returns the top lefthand corner location on the screen, or None if the element is not visible
		
			return [$driver location_once_scrolled_into_view $element_ID]			
		}
		
		method size {} {
			# Returns the size of the element
			return [$driver size $element_ID]
		}
		
		method css_property {property_name} {
			# Returns the value of a CSS property

			return [$driver css_property $element_ID $property_name]
		}
		
	
		method get_location {} {
			# Returns the location of the element in the renderable canvas
		
			return [$driver get_location $element_ID]			
		}
		
		method get_rect {} {
			# Returns a dictionary with the size and location of the element
			return [$driver get_rect $element_ID]
		}
		
		method send_keys {string_of_keys} {
			# Simulates typing into the element.
			# 
			# :Args:
			# - value - A string for typing, or setting form fields.  For setting
			# file inputs, this could be a local file path.
			# 
			# Use this to send simple key events or to fill out form fields::
			# 
			# set form_textfield [$driver find_element -name username]
			# $driver send_keys -el $form_textfield -string admin
			# $driver send_keys admin $form_textfield

			$driver execute $Command(SEND_KEYS_TO_ELEMENT) id $element_ID value [split $string_of_keys ""] text $string_of_keys
		}
		
        method select_element {command_var} {
           upvar $command_var select_element
           set select_element [Select_Element $driver $element_ID]
           
           trace add variable select_element unset "$select_element destroy"
        }

		method find_element {args} {
            return [$driver find_element {*}$args -root $element_ID -level 1]
		}
				
		method find_elements {args} {
            return [$driver find_elements {*}$args -root $element_ID -level 1]
		}        
        method get_screenshot_as_base64 {} {
            return [$driver get_screenshot_as_base64 $element_ID]
        }
        method get_screenshot_as_png {} {
            return [$driver get_screenshot_as_png $element_ID]
        }
        method get_screenshot_as_file {filename} {
            $driver get_screenshot_as_file $filename $element_ID
        }
    }
}

