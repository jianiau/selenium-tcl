namespace eval ::selenium {

	oo::class create Mixin_For_Element_Retrieval {
        variable driver By Command w3c_compliant
                
        method OptionsForElementRetrieval {arguments} {
            if {[llength $arguments] % 2 != 0} {
                tailcall return -code error "Wrong number of arguments"
            }
            
			set using ""
            set command_var ""
            
            set level 1
            set root_element ""
			
			foreach {optionName optionValue} $arguments {
                        
				switch -exact $optionName {
					-id -
					-xpath -
					-name -
					-link_text -
					-tag_name -
					-partial_link_text -
					-css -
					-class {
						if {$using ne ""} {
							tailcall return -code error "The locator strategy has been setted before: $optionName"
						}
						set using $By($optionName)
						set value $optionValue
					}
                    -root {
                        if {$root_element ne ""} {
							tailcall return -code error "The target element was '$root_element'"
						}
                        set root_element $optionValue
                    }
                    -level {
                        incr level $optionValue
                    }
                    -command_var {
                        if {$command_var ne ""} {
                            tailcall return -code error "The command_var was '$command_var'"
                        }
                        set command_var $optionValue
                    }
					default {
						tailcall return -code error "Invalid option: $optionName"
					}
					
				}
			}
            
            if {$w3c_compliant} {
                if {$using eq $By(-id)} {
                    set using $By(-css)
                    set value "\[id=\"$value\"\]"
                } elseif {$using eq $By(-tag_name)} {
                    set using $By(-css)
                } elseif {$using eq $By(-class)} {
                    set using $By(-css)
                    set value ".$value"
                } elseif {$using eq $By(-name)} {
                    set using $By(-css)
                    set value "\[name=\"$value\"\]"
                }
            }

            return [list using $using value $value root_element $root_element level $level command_var $command_var]
        }
        
        method find_element {args} {
			#
			# Find element by strategy location
			#
			# :Args:
			# - strategy location:
			#		-id
			#		-xpath
			#		-name
			#		-link_text 
			#		-tag_name
			#		-partial_link_text
			#		-css
			#		-class
			#		-link_text
            # - It's possible to find a descendant element from another element, indicating its element ID
            #        -root *element_ID*
            # - Build a new command if you want to apply several acctions to this element to avoid adding 
            # always its element ID. A new webelement object will be created.
            #       - command_var *name_of_command_variable*
			# :Usage:
			#	driver find_element -css ".foo"

            array set options [my OptionsForElementRetrieval $args]
            
			if {$options(root_element) ne ""} {
				set response [my execute $Command(FIND_CHILD_ELEMENT) using $options(using) value $options(value) id $options(root_element)]
			} else {
				set response [my execute $Command(FIND_ELEMENT) using $options(using) value $options(value)]
			}
			
            if {[dict exists $response value ELEMENT]} {
                set element_ID [dict get $response value ELEMENT]
            } elseif {[dict exists $response value element-6066-11e4-a52e-4f735466cecf]} {
                set element_ID [dict get $response value element-6066-11e4-a52e-4f735466cecf]
            } else {
                throw $Exception(WebdriverException) "No element ID found:\n$response"
            }
            
            if {$options(command_var) ne ""} {
                $driver create_webelement $element_ID $options(command_var) [expr $options(level) +1]
            }
            
			return $element_ID
		}
   
        method find_elements {args} {
			#
			# Finds elements by strategy location
			#
            # It has the same options than find_element.
            # The option "-command_var" builds a container of webelements object.
            #
			# :Usage:
			#	driver find_elements -css ".foo"

            array set options [my OptionsForElementRetrieval $args]
			
			if {$options(root_element) ne ""} {
				set response [my execute $Command(FIND_CHILD_ELEMENTS) using $options(using) value $options(value) id $options(root_element)]
			} else {
				set response [my execute $Command(FIND_ELEMENTS) using $options(using) value $options(value)]
			}
							
			set list_of_element_IDs [list]
						
			foreach element [dict get $response value] {
                if {[dict exists $element ELEMENT]} {
                    lappend list_of_element_IDs [dict get $element ELEMENT]
                } elseif {[dict exists $element element-6066-11e4-a52e-4f735466cecf]} {
                    lappend list_of_element_IDs [dict get $element element-6066-11e4-a52e-4f735466cecf]
                } else {
                    throw $Exception(WebdriverException) "No element ID found:\n$element"
                }
			}
            
            if {$options(command_var) ne ""} {
                $driver create_container_of_webelements $list_of_element_IDs $options(command_var) [expr $options(level) +1]
            }

            return $list_of_element_IDs
		}

        method find_element_by_id {id_ args} {
            # Finds an element by id.
            # 
            # :Args:
            # - id_ - The id of the element to be found.
            # 
            # :Usage:
            #    $driver find_element_by_id foo
    
            return [my find_element -id $id_ -level 1 {*}$args]
        }
    
        method find_elements_by_id {id_ args} {
            # Finds multiple elements by id.
            # 
            # :Args:
            # - id\_ - The id of the elements to be found.
            # 
            # :Usage:
            #    $driver find_element_by_id foo
    
            return [my find_elements -id $id_ -level 1 {*}$args]
        }
    
        method find_element_by_xpath {xpath args} {
            # Finds an element by xpath.
            # 
            # :Args:
            # - xpath - The xpath locator of the element to find.
            # 
            # :Usage:
            #    $driver find_element_by_xpath {//div/td[1 -level 1 {*}$args]}
    
            return [my find_element -xpath $xpath -level 1 {*}$args]
    
        }
    
        method find_elements_by_xpath {xpath args} {
            # Finds multiple elements by xpath.
            # 
            # :Args:
            # - xpath - The xpath locator of the elements to be found.
            # 
            # :Usage:
            #    $driver find_elements_by_xpath {//div[contains(@class, foo -level 1 {*}$args]}
    
            return [my find_elements -xpath $xpath -level 1 {*}$args]
    
        }
    
        method find_element_by_link_text {link_text args} {
            # Finds an element by link text.
            # 
            # :Args:
            # - link_text: The text of the element to be found.
            # 
            # :Usage:
            #    $driver find_element_by_link_text {Sign In}
    
            return [my find_element -link_text $text -level 1 {*}$args]
    
        }
    
        method find_elements_by_link_text {text args} {
            # Finds elements by link text.
            # 
            # :Args:
            # - link_text: The text of the elements to be found.
            # 
            # :Usage:
            #    $driver find_elements_by_link_text 'Sign In'
    
            return [my find_elements -link_text $text -level 1 {*}$args]
    
        }
    
        method find_element_by_partial_link_text {link_text args} {
            # Finds an element by a partial match of its link text.
            # 
            # :Args:
            # - link_text: The text of the element to partially match on.
            # 
            # :Usage:
            #    $driver find_element_by_partial_link_text Sign
    
            return [my find_element -partial_link_text $link_text -level 1 {*}$args]
    
        }
    
        method find_elements_by_partial_link_text {link_text args} {
            # Finds elements by a partial match of their link text.
            # 
            # :Args:
            # - link_text: The text of the element to partial match on.
            # 
            # :Usage:
            #    $driver find_element_by_partial_link_text Sign
    
            return [my find_elements -partial_link_text $link_text -level 1 {*}$args]
    
        }
    
        method find_element_by_name {name args} {
            # Finds an element by name.
            # 
            # :Args:
            # - name: The name of the element to find.
            # 
            # :Usage:
            #    $driver find_element_by_name foo
    
            return [my find_element -name $name -level 1 {*}$args]
    
        }
    
        method find_elements_by_name {name args} {
            # Finds elements by name.
            # 
            # :Args:
            # - name: The name of the elements to find.
            # 
            # :Usage:
            #    $driver find_elements_by_name foo
    
            return [my find_elements -name $name -level 1 {*}$args]
    
        }
    
        method find_element_by_tag_name {name args} {
            # Finds an element by tag name.
            # 
            # :Args:
            # - name: The tag name of the element to find.
            # 
            # :Usage:
            #    $driver find_element_by_tag_name foo
    
            return [my find_element -tag_name $name -level 1 {*}$args]
    
        }
    
        method find_elements_by_tag_name {name args} {
            # Finds elements by tag name.
            # 
            # :Args:
            # - name: The tag name the use when finding elements.
            # 
            # :Usage:
            #    $driver find_elements_by_tag_name foo
    
            return [my find_elements -tag_name $name -level 1 {*}$args]
    
        }
    
        method find_element_by_class_name {name args} {
            # Finds an element by class name.
            # 
            # :Args:
            # - name: The class name of the element to find.
            # 
            # :Usage:
            #    $driver find_element_by_class_name foo
    
            return [my find_element -class $name -level 1 {*}$args]
    
        }
    
        method find_elements_by_class_name {name args} {
            # Finds elements by class name.
            # 
            # :Args:
            # - name: The class name of the elements to find.
            # 
            # :Usage:
            #    $driver find_elements_by_class_name foo
    
            return [my find_elements -class $name -level 1 {*}$args]
    
        }
    
        method find_element_by_css_selector {css_selector args} {
            # Finds an element by css selector.
            # 
            # :Args:
            # - css_selector: The css selector to use when finding elements.
            # 
            # :Usage:
            #    $driver find_element_by_css_selector #foo
    
            return [my find_element -css $css_selector -level 1 {*}$args]
    
        }
    
        method find_elements_by_css_selector {css_selector args} {
            # Finds elements by css selector.
            # 
            # :Args:
            # - css_selector: The css selector to use when finding elements.
            # 
            # :Usage:
            #    $driver find_elements_by_css_selector .foo
    
            return [my find_elements -css $css_selector -level 1 {*}$args]
        }
    }
}
