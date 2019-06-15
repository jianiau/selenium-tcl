package require lambda

namespace eval ::selenium {
	namespace export expected_condition
}

namespace eval ::selenium::expected_condition {
	# Canned "Expected Conditions" which are generally useful within webdriver tests.

	namespace export *
	namespace ensemble create -prefixes false
	
	proc title_is {title} {
		# An expectation for checking the title of a page.
		# title is the expected title, which must be an exact match
		# returns 1 if the title matches, 0 otherwise.
				
		return [lambda {title driver} {
			if {$title eq [$driver title]} {
				return true
			} else {
				return false
			}
		} $title]
	}
	
	proc title_contains {text} { 
		# An expectation for checking that the title contains a case-sensitive substring. 
		# text is the fragment of title expected
		# returns 1 when the title matches, 0 otherwise
	
		return [lambda {text_in_title driver} {
			if {[string first [$driver title] $text_in_title] != -1} {
				return true
			} else {
				return false
			}
		} $text]
	}
	
	proc presence_of_element_located {by value {element ""}} {
		# An expectation for checking that an element is present on the DOM
		# of a page. This does not necessarily mean that the element is visible.
                
		return [lambda {by value element driver} {
            try {
				if {$element eq ""} {
                    $driver find_element $by $value
                } else {
                    $driver find_element $by $value -root $element
                }
                
				return true
			} trap $::selenium::Exception(NoSuchElement) {} {
				return false
			}
		} $by $value $element]
	}
	
	proc visibility_of_element_located {by value} {
		# An expectation for checking that an element is present on the DOM of a
		# page and visible. Visibility means that the element is not only displayed
		# but also has a height and width that is greater than 0.
        
        return [lambda {by value driver} {
            namespace upvar ::selenium::Exception Exception
            
			try {
				set element [$driver find_element $by $value]
			} trap $::selenium::Exception(StaleElementReference) {} {
				return false
			} trap $::selenium::Exception(NoSuchElement) {} {
				return false
            }
            
            if [$driver is_displayed $element] {
                return true
            } else {
                return false
            }
		} $by $value]
	}
	
	proc visibility_of {element} {
		# An expectation for checking that an element, known to be present on the
		# DOM of a page, is visible. Visibility means that the element is not only
		# displayed but also has a height and width that is greater than 0.
		# element is the WebElement
        
        return [lambda {element driver} {
            try {
				if [$driver is_displayed $element] {
					return true
				} else {
					return false
				}
			} trap $::selenium::Exception(StaleElementReference) {} {
				return false
			}
		} $element]
	}
	
	proc text_to_be_present_in_element {by value text} {
		# An expectation for checking if the given text is present in the specified element by locator.
        
        return [lambda {by value text driver} {
            try {
                set element [$driver find_element $by $value]
                set element_text [$driver get_visible_text $element]
                
				if {[string first $element_text $text] != -1} {
					return true
				} else {
					return false
				}
			} trap $::selenium::Exception(StaleElementReference) {} {
				return false
			}
		} $by $value $text]
	}
	
	 proc text_to_be_present_in_element_value {by value text} {
		# An expectation for checking if the given text is present in the element's
		# locator, text
	
		return [lambda {by value text driver} {            
			try {
                $driver find_element element @by@ {@value@}
				set element_text [$element get_attribute value]

				if {$element_text ne ""} {
					if {[string first $element_text @text@] != -1} {
						return true
					} else {
						return false
					}
				} else {
					return false
				}
			} trap $::selenium::Exception(StaleElementReference) {} {
				return false
			}
		} $by $value $text]		
	}

    proc element_has_this_attribute_value {element attribute_name attribute_value} {
		# An expectation for checking if the given element has an specific attribute name and value
        
		return [lambda {element attribute_name attribute_value driver} {
            if {[$driver get_attribute $element $attribute_name] eq $attribute_value} {
                return true
            } else {
                return false
            }

		} $element $attribute_name $attribute_value]		
	}
   		
	proc frame_to_be_available_and_switch_to_it {optionName optionValue} {
		# An expectation for checking whether the given frame is available to
		# switch to.  If the frame is available it switches the given driver to the
		# specified frame.

        switch -exact -- $optionName {
            -id -
            -css -
            -xpath {
                return [lambda {by value driver} {
                    try {
                        set element [$driver find_element element $by $value]
                        $driver switch_to_frame -element $element
                        return true
                    } trap $::selenium::Exception(NoSuchFrame) {} {
                        return false
                    } trap $::selenium::Exception(NoSuchElement) {} {
                        return false
                    }
                } $optionName $optionValue]
			}
            -element -
			-index -
			-name {
                return [lambda {optionName optionValue driver} {
                    try {
                        $driver switch_to_frame $optionName $optionValue
                        return true
                    } trap $::selenium::Exception(NoSuchFrame) {} {
                        return false
                    }
                } $optionName $optionValue]
            }
            default {
                return -code error "Invalid option: '$optionName'"
			}
		}
	}

	proc invisibility_of_element_located {by value} {
		# An Expectation for checking that an element is either invisible or not
		# present on the DOM.
		# In the case of NoSuchElement, returns true because the element is
		# not present in DOM. The try block checks if the element is present
		# but is invisible.
		# In the case of StaleElementReference, returns true because stale
		# element reference implies that element is no longer visible.
		
		return [lambda {by value driver} {
            try {
				$driver find_element $by $value
				
				return false
			} trap $::selenium::Exception(NoSuchElement) {} {
				return true
			} trap $::selenium::Exception(StaleElementReference) {} {
				return true
			}
        } $by $value]
	}
    
    proc invisibility_of_all_elements_located {by value} {
		# An Expectation for checking that all elements indicated are invisible

		return [lambda {by value driver} {
            set container_of_elements [$driver find_elements $by $value]
            
            set all_elements_are_invisible true
            foreach element $container_of_elements {
                if {[$driver is_displayed $element]} {
                    set all_elements_are_invisible false
                    break
                }
            }
            
            return $all_elements_are_invisible

		} $by $value]

	}
	
	proc element_to_be_clickable {by value} {
		# An Expectation for checking an element is visible and enabled such that you can click it.
		
		return [lambda {by value driver} {
            try {
				set element [$driver find_element $by $value]
				if {[$driver is_displayed $element] && [$driver is_enabled $element]} {
					return true
				} else {
					return false
				}
			} trap $::selenium::Exception(StaleElementReference) {
				return false
			}
        } $by $value]
	}
	
	proc staleness_of {element} {
		# Wait until an element is no longer attached to the DOM.
		# element is the element to wait for.
		# returns False if the element is still attached to the DOM, true otherwise.
		
		# Calling any method forces a staleness check
		
		return [lambda {element driver} {
            try {
				# Calling any method forces a staleness check
				$driver is_enabled $element
				
				return false
			} trap $::selenium::Exception(StaleElementReference) {} {
				return true
			}
        } $element]
	}
	
	proc element_to_be_selected {element} {
		# An expectation for checking the selection is selected.
		# element is WebElement object
		
		return [lambda {element driver} {
            if [$driver is_selected @element@] {
				return true
			} else {
				return false
			}
        } $element]
	}
	
	proc element_located_to_be_selected {by value} {
		#An expectation for the element to be located is selected.
		
		return [lambda {by value driver} {
            set element [$driver find_element element $by $value]
			
			if [$driver is_selected $element] {
				return true
			} else {
				return false
			}
        } $by $value]
	}

	proc element_selection_state_to_be {element is_selected} {
		# An expectation for checking if the given element is selected.
		# element is WebElement object
		# is_selected is a Boolean."
		
		set is_selected [expr !!$is_selected]

		return [lambda {element is_selected driver} {
            if {[$driver is_selected $element] == $is_selected} {
				return true
			} else {
				return false
			}
		} $element $is_selected]
		
	}
	
	proc element_located_selection_state_to_be {by value is_selected} {
		# An expectation to locate an element and check if the selection state
		# specified is in that state.
		# by is the strategy of location
		# value is the parameter value for that strategy
		# is_selected is a boolean
        
		set is_selected [expr !!$is_selected]
		
		return [lambda {element is_selected driver} {
            try {
				
				$driver find_element element @by@ {@value@}
			
				if { !![$element is_selected] == @is_selected@} {
					return true
				} else {
					return false
				}
			} except $::selenium::Exception(StaleElementReference) {} {
				return false
			}
        } $element $is_selected]
	}
		

	proc alert_is_present {} {
		# Expect an alert to be present.
        		
		return [lambda driver {
            try {
				$driver text_of_alert
				
				return true
			} trap $::selenium::Exception(NoAlertPresentException) {} {
				return false
			}
        }]
	}
}


interp alias {} ::selenium::EC {} ::selenium::expected_condition
