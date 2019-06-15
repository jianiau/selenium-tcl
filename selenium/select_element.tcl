package require selenium::utils::selectors

namespace eval ::selenium {
    namespace export Select_Element
        
	oo::class create Select_Element {        
        variable Exception is_multiselect
        
        method Initialize_mixin {} {
            namespace import \
                ::selenium::utils::selectors::escape_string_in_xpath \
                ::selenium::utils::selectors::escape_string_in_css
                
            set multiple_attribute [my get_attribute multiple]
            set is_multiselect [expr {$multiple_attribute ne "" && $multiple_attribute ne "false"}]
        }
                        
        method options {} {
            # Returns a list of all options belonging to this select tag
    
            return [my find_elements -tag_name option]
        }
        
        method selected_options {} {
            # Returns a list of all selected options belonging to this select tag
    
            set webelement [self]
            
            set list_of_selected_options [list]
            [my options] foreach opt {
                if {[$opt is_selected]} {
                    lappend list_of_selected_options $opt
                }
            }
            
            return $list_of_selected_options
        }
    
        method first_selected_option {} {
            # The first selected option in this select tag (or the currently selected option in a
            # normal select)
                
            [my options] foreach opt {
                if {[$opt is_selected]} {
                    return $opt
                }
            }
            
            throw $Exception(NoSuchElement) "No options are selected"
        }
        
        method select_option {args} {
            foreach {optionName optionValue} $args {
                switch -exact $optionName {
                    -value {
                        select_option_by_value $optionValue
                    }
                    -index {
                        select_option_by_index $optionValue
                    }
                    -visible_text {
                        select_option_by_visible_text $optionValue
                    }
                }
            }
        }
        
        method deselect_option {args} {
            foreach {optionName optionValue} $args {
                switch -exact $optionName {
                    -value {
                        deselect_option_by_value $optionValue
                    }
                    -index {
                        deselect_option_by_index $optionValue
                    }
                    -visible_text {
                        deselect_option_by_visible_text $optionValue
                    }
                }
            }
        }
    
        method select_option_by_value {value} {
            # Select all options that have a value matching the argument. That is, when given "foo" this
            # would select an option like:
            # 
            # <option value="foo">Bar</option>
            # 
            # :Args:
            # - value - The value to match against
    
            set css "option\[value= '[escape_string_in_css $value]'\]"
            my find_elements container_of_options -css $css
    
            if {[$container_of_options length] == 0} {
                throw $Exception(NoSuchElement) "Cannot locate option with value: $value"
            }        
            
            if {$is_multiselect} {
                $container_of_options foreach opt {
                    my set_option_selected $opt
                }
            } else {
                my set_option_selected [$container_of_options index 0]
            }
            
        }
    
        method select_option_by_index {index} {
            # Select the option at the given index. This is done by examing the "index" attribute of an
            # element, and not merely by counting.
            # 
            # :Args:
            # - index - The option at this index will be selected
    
        
            set matched false
            
            set container_of_options [my options]
            
            if {[$container_of_options length] == 0} {
                throw $Exception(NoSuchElement) "There is no option in select element"
            }  
            
            $container_of_options foreach opt {
                if {[$opt get_element_attribute index] == $index} {
                    my set_option_selected $opt
                    set matched true
                    break
                }
            }
            
            if {!$matched} {
                throw $Exception(NoSuchElement) "Could not locate element with index $index"
            }
    
        }
    
        method select_option_by_text {text} {
            # Select all options that display text matching the argument. That is, when given "Bar" this
            # would select an option like:
            # 
            # <option value="foo">Bar</option>
            # 
            # :Args:
            # - text - The visible text to match against
    
            set xpath ".//option\[normalize-space(.) = [escape_string_in_xpath $text]\]"
            set container_of_options [my find_elements -xpath $xpath]
            
            if { [$container_of_options length] != 0 } {
                if {$is_multiselect} {
                    $container_of_options foreach opt {
                        my set_option_selected $opt
                    }    
                } else {
                    my set_option_selected [$container_of_options index 0]
                }
                
            } else {
                throw $Exception(NoSuchElement) "Could not locate element with visible text: $text"
            }
    
        }
    
        method deselect_all {} {
            # Clear all selected entries. This is only valid when the SELECT supports multiple selections.
            # throws NotImplementedError If the SELECT does not support multiple selections
            
            if {!$is_multiselect} {
                error "You may only deselect options of a multi-select"
            }
            
            set container_of_options [my options $select_element]
            
            $container_of_options foreach opt {
                my set_option_unselected $opt
            }
        }
    
        method deselect_option_by_value {value} {
            # Deselect all options that have a value matching the argument. That is, when given "foo" this
            # would deselect an option like:
            # 
            # <option value="foo">Bar</option>
            # 
            # :Args:
            # - value - The value to match against
            
            if {!$is_multiselect} {
                error "You may only deselect options of a multi-select"
            }
            
            set css "option\[value = [my escape_string_in_css $value]\]"
            set container_of_options [my find_elements -css $css]
            $container_of_options foreach opt {
                my set_option_unselected $opt
            }
    
        }
    
        method deselect_option_by_index {index} {
            # Deselect the option at the given index. This is done by examing the "index" attribute of an
            # element, and not merely by counting.
            # 
            # :Args:
            # - index - The option at this index will be deselected
            
            if {!$is_multiselect} {
                error "You may only deselect options of a multi-select"
            }
    
            set container_of_options [my options $select_element]
            
            $container_of_options foreach opt {
                if {[$opt get_attribute index] == $index} {
                    my set_option_unselected $opt
                    break
                }
            }
            
        }
    
        method deselect_option_by_visible_text {text} {
            # Deselect all options that display text matching the argument. That is, when given "Bar" this
            # would deselect an option like:
            # 
            # <option value="foo">Bar</option>
            # 
            # :Args:
            # - text - The visible text to match against
            
            if {!$is_multiselect} {
                error "You may only deselect options of a multi-select"
            }
            
            set xpath ".//option\[normalize-space(.) = [escape_string_in_xpath $text]\]"
            set container_of_options [my find_elements -xpath $xpath]
            $container_of_options foreach $opt {
                my set_option_unselected $opt
            }
    
        }
    
        method set_option_selected {option} {
            if {![$option is_selected]} {
                $option click
            }
        }
    
        method set_option_unselected {option} {
            if {[$option is_selected]} {
                $option click 
            }
        }
        
    }
    
}
