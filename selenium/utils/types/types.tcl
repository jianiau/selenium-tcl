# types.tcl
#
#   It is published with the terms of tcllib's BSD-style license.
#
# This library provide functions to create and manipulate typed objects.
#
# Copyright (c) 2015 Miguel Martínez López


package provide selenium::utils::types 0.1.0

package require Tcl 8.5
package require TclOO       ; # For 8.5. Integrated with 8.6

namespace eval ::types {
    namespace export Dict List String Boolean Number Null get_obj set_obj remove_obj
}

proc ::types::get_obj {obj args} {
    foreach index $args {
        set obj [$obj get $index]
    }
    return $obj
}

proc ::types::set_obj {obj args} {
    set new_value [lindex $args end]
    
    set penultimate_index [expr [llength $args]-3]
    for {set index 0} {$index <= $penultimate_index} {incr index} {
        set obj [$obj get $index]
    }
    $obj set [lindex $args end-1] $new_value
}

proc ::types::remove_obj {obj args} {
    set penultimate_index [expr [llength $args]-2]
    for {set index 0} {$index <= $penultimate_index} {incr index} {
        set obj [$obj get $index]
    }
    $obj remove [lindex $args end]
}

# data is plain old tcl values
# spec is defined as follows:
# {string} - data is simply a string, "quote" it if it's not a number
# {list} - data is a tcl list of strings, convert to JSON arrays
# {list list} - data is a tcl list of lists
# {list dict} - data is a tcl list of dicts
# {dict} - data is a tcl dict of strings
# {dict xx list} - data is a tcl dict where the value of key xx is a tcl list
# {dict * list} - data is a tcl dict of lists
# etc..
proc ::types::compile {spec data} {

    while {[llength $spec]} {
        set type [lindex $spec 0]
        set spec [lrange $spec 1 end]

        switch -- $type {
            dict {
                if {![llength $spec]} {
                    lappend spec * string
                }

                set dict_src [list]
                foreach {key value} $data {
                    foreach {matching_key subspec} $spec {
                        if {[string match $matching_key $key]} {
                            lappend dict_src $key [compile $subspec $value]
                            break
                        }
                    }
                }
                
                return [Dict new {*}$dict_src]
            }
            
            list {
                if {![llength $spec]} {
                    set spec string
                } else {
                    set spec [lindex $spec 0]
                }
                
                set list_src [list]
                foreach list_item $data {
                    lappend list_src [compile $spec $list_item]
                }
            
                return [List new {*}$list_src]
            }
        
            string {
                return [String new $data]
            }
        
            number {
                return [Number new $data]
            }
            boolean -
            bool {
                return [Boolean new $data]
            }
        
            null {
                if {$data eq ""} {
                    return [Null new]
                } else {
                    error "Data must be an empty string: '$data'"
                }
            }
            typed_object {
                return $data
            }
        
            default {error "Invalid type: '$type'"}
        }
    }
}

oo::class create ::types::Type {
    variable tag parent_container
    method tag {} {
        return $tag
    }
    
    method contained_in {container} {
        if {[info exists parent_container]} {
            return -code error "The container has been set before"
        } else {
            set parent_container $container
        }
    }        
    
    method raw {} {
        return -code "Not implemented method"
    }
    
    method repr {} {
        return -code "Not implemented method"
    }
}

oo::class create ::types::Container_Type {
    superclass ::types::Type
    variable value
    
    method clone {} {
        return [[info object class [self]] new {*}$value]
    }
}
oo::class create ::types::Simple_Type {
    superclass ::types::Type
    
    variable value tag
    
    method clone {} {
        return [[info object class [self]] new $value]
    }

    method raw {} {
        return $value
    }
    
    method repr {} {
        return [list $tag $value]
    }
}
    
oo::class create ::types::Dict {
    superclass ::types::Container_Type
    variable tag value
    
    constructor {args} {
        set tag D
        
        foreach {key element} $args {
            $element contained_in [self]
        }
        
        set value [dict create {*}$args]
    }
    
    method raw {} {
        set raw_elements [list]
        
        dict for {key element} $value {
            lappend raw_elements $key [$element raw]
        }
        return $raw_elements
    }
    
    method repr {} {
        set representation_of_elements [list]
        
        dict for {key element} $value {
            lappend representation_of_elements $key [$element repr]
        }
        return [list $tag $representation_of_elements]
    }
    
    method exists {key} {
        return [dict exists $value $key]
    }
    
    method length {} {
        return [dict size $value]
    }
    
    method keys {} {
        return [dict values $value]
    }
    
    method values {} {
        return [dict keys $value]
    }
    
    method get {key} {
        return [dict get $value $key]
    }
    
    method set {args} {
        foreach {key newValue} $args {
            if {[dict exists $value $key]} {
                set element [dict get $value $key]
                $element destroy
            }
            dict set value $key $newValue
        }
    }
    
    method for {list_of_vars body} {
        uplevel [list dict for $list_of_vars $value $body]
    }
    
    method remove {key} {
        set element [dict get $value $key]
        $element destroy
        
        dict unset value $key
    }
    
    method to_json {} {
        if {[dict size $value] == 0} {
            return "{}"
        }
        
        set list_of_raw_json [list]
        dict for {key element} $value {
            set key [string map {
                    \n \\n
                    \t \\t
                    \r \\r
                    \b \\b
                    \f \\f
                    \\ \\\\
                    \" \\\"
                    / \\/} $key]
            lappend list_of_raw_json "\"$key\":[$element to_json]"
        }
            
        return "{[join $list_of_raw_json ,]}"
    }
    
    destructor {
        foreach element [dict values $value] {
            $element destroy
        }
    }
}

oo::class create ::types::List {
    superclass ::types::Container_Type
    variable tag value
    
    constructor {args} {
        set tag L
        
        foreach element $args {
            $element contained_in [self]
        }
        
        set value $args
    }
    
    method repeat {count} {
        set value [lrepeat $count $value[set value ""]]
        return [self]
    }
    
    method reverse {} {
        set value [lreverse $value[set value ""]]
    }
    
    method append {args} {
        foreach element $args {
            $element contained_in [self]
        }
        
        lappend value {*}$args
    }
            
    method repr {} {
        set representation_of_elements [list]
        
        foreach element $value {
            lappend representation_of_elements [$element repr]
        }
        return [list $tag $representation_of_elements]
    }
    
    method raw {} {
        set raw_elements [list]
        
        foreach element $value {
            lappend raw_elements [$element raw]
        }
        return $raw_elements
    }
    
    method length {obj} {
        return [llength $value]
    }
    
    method get {index} {
        return [lindex $value $index]
    }
    
    method set {args} {
        foreach {index newValue} $args {
            set element [lindex $value $index]
            
            $element destroy
            lset value $index $newValue
        }
        return [self]
    }
    
    method to_json {} {
        if {[llength $value] == 0} {
            return \[\]
        }
        
        set list_of_raw_json [list]
        
        foreach element $value {
            lappend list_of_raw_json [$element to_json]
        
        }
        
        return \[[join $list_of_raw_json ,]\]
    }
    
    method remove {index} {
        set element [lindex $value $index]
        $element destroy
        
        set value [lreplace $value[set value ""] $index $index]
    }
    
    destructor {
        foreach element $value {
            $element destroy
        }
    }
}

oo::class create ::types::Number {
    superclass ::types::Simple_Type
    variable tag value
    
    constructor {number} {
        set tag num
        
        if {![string is double $number]} {
            return -code error "It's not a number: $number"
        }
        set value $number
    }
    
    method incr {quantity} {
        incr value $quantity
    }
    
    method add {quantity} {
        set value [expr {$value + $quantity}]
    }
    
    method mult {quantity} {
        set value [expr {$value * $quantity}]
    }
    
    method to_json {} {
        return $value
    }
}

oo::class create ::types::Boolean {
    superclass ::types::Simple_Type
    variable tag value
    
    constructor {boolean_expression} {
        set tag b
        
        if {![string is boolean $boolean_expression]} {
            return -code error "Bad boolean: $boolean_expression"
        }
        
        if {$boolean_expression} {
            set value true
        } else {
            set value false
        }
    }
    
    method is_false {} {
        if {$value eq "false"} {
            return 1
        } else {
            return 0
        }
    }
    
    method is_true {} {
        if {$value eq "true"} {
            return 1
        } else {
            return 0
        }
    }
    
    method to_json {} {
        return $value
    }
}

oo::class create ::types::String {
    superclass ::types::Simple_Type
    variable tag value
    
    constructor {text} {
        set tag s
        set value $text
    }
    
    method cat {args} {
        set value [string cat $value {*}$args]
        return [self]
    }
    
    method repeat {count} {
        set value [string repeat $value $count]
        return [self]
    }
            
    method wordstart {charIndex} {
        return [string wordstart $value $charIndex]]
    }
    
    method wordend {charIndex} {
        return [string wordend $value $charIndex]]
    }
    
    method length {} {
        return [string length $value]
    }
    
    method range {first last} {
        set value [string range $value $first $last]
        
        return [self]
    }
    
    method trim {{chars ""}} {
        if {$chars eq ""} {
            set value [string trim $value]]
        } else {
            set value [string trim $value $chars]]
        }
        
        return [self]
    }
    
    method trimleft {{chars ""}} {
        if {$chars eq ""} {
            set value [string trimleft $value]]
        } else {
            set value [string trimleft $value $chars]]
        }
        
        return [self]
    }
    
    method trimright {{chars ""}} {
        if {$chars eq ""} {
            set value [string trimright $value]]
        } else {
            set value [string trimright $value $chars]]
        }
        
        return [self]
    }
    
    method index {charIndex} {
        return [string index $value $charIndex]]
    }
    
    method replace {first last {newstring ""}} {
        set value [string replace $first $last $value $newstring]
        
        return [self]
    }
    
    method reverse {} {
        set value [string reverse $value]
        
        return [self]
    }
    
    method tolower {{first 0} {last end}} {
        set value [string tolower $value $first $last]
        return [self]
    }
    
    method totitle {{first 0} {last end}} {
        set value [string totitle $value $first $last]
        return [self]
    }
    
    method toupper {{first 0} {last end}} {
        set value [string toupper $value $first $last]
        return [self]
    }
    
    method first {string {startIndex 0}} {
        return [string first $value $string $startIndex]
    }
    
    method last {string {startIndex 0}} {
        return [string last $value $string $startIndex]
    }
    
    method is {class args} {
        return [string is $class {*}$args $value]
    }
    
    method map {args} {
        set value [string map $args $value]
        return [self]
    }
    
    method match {args} {
        return [string match {*}$args $value]
    }
    
    method to_json {} {
        # JSON permits only oneline string
        return \"[string map {
                    \n \\n
                    \t \\t
                    \r \\r
                    \b \\b
                    \f \\f
                    \\ \\\\
                    \" \\\"
                    / \\/} $value]\"
    }
}

oo::class create ::types::Null {
    superclass ::types::Simple_Type
    variable tag
    
    constructor {} {
        set tag null
    }
    
    method to_json {} {
        return null
    }
    
    method raw {} {
        return ""
    }
    
    method repr {} {
        return [list null]
    }
}
