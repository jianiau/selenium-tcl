# -*- tcl -*-
# (c) 2016 Miguel Martínez López

package require Tcl 8.6
package require selenium::utils::types 0.1.0

package provide selenium::utils::types::json 0.1

oo::class create ::types::JSON_2_typedObj {
    
    variable cursor jsonText EndOfTextException numberRE
    
    constructor {} {
        namespace import ::types::String ::types::Dict ::types::List ::types::Boolean ::types::Number ::types::Null
        
        set positiveRE {[1-9][[:digit:]]*}
        set cardinalRE "-?(?:$positiveRE|0)"
        set fractionRE {[.][[:digit:]]+}
        set exponentialRE {[eE][+-]?[[:digit:]]+}
        set numberRE "${cardinalRE}(?:$fractionRE)?(?:$exponentialRE)?"
    
        # Exception code for "End of Text" signal
        set EndOfTextException 5
    }        
        
    method parse {json_to_parse} {
        set cursor -1
        set jsonText $json_to_parse
        
        my ParseNextData
    }
        
    method PeekChar {{increment 1}} {
        return [string index $jsonText [expr $cursor+$increment]]
    }

    method AdvanceCursor {{increment 1}} {
        incr cursor $increment
    }
    
    method NextChar {} {
        if {$cursor + 1 < [string length $jsonText] } {
            incr cursor
            return [string index $jsonText $cursor]    
        } else {
            return -code $EndOfTextException
        }
    }

    method AssertNext {ch {target ""}} {
        incr cursor
        
        if {[string index $jsonText $cursor] != $ch} {
            if {$target == ""} {
                set target $ch
            }
            throw {TYPES JSONparser} "Trying to read the string $target at index $cursor."
        }
    }


    method ParseNextData {} {
        
        my EatWhitespace
        
        set ch [my PeekChar]
        
        if {$ch eq ""} {
            throw {TYPES JSONparser} {Nothing to read}
        }
        
                    
        switch -exact -- $ch {
            "\{" {
                return [my ReadObject]
            } 
            "\[" {
                return [my ReadArray]
            } 
            "\"" {
                return [my ReadString]
            } 

            "t" {
                return [my ReadTrue]
            }
            "f" {
                return [my ReadFalse]
            }
            "n" {
                return [my ReadNull]
            } 
            "/" {
                my ReadComment
                return [my ParseNextData]
            }
            "-" -
            "0" -
            "1" -
            "2" -
            "3" -
            "4" -
            "5" -
            "6" -
            "7" -
            "8" -
            "9" {
                return [my ReadNumber]
            } 
            default {
                throw {TYPES JSONparser} "Input is not valid JSON: '$jsonText'" 
            }
        }
    }
    
    method EatWhitespace {} {

        while {true} {
            set ch [my PeekChar]
            
            if [string is space -strict $ch] {
                my AdvanceCursor
            } elseif {$ch eq "/"} {
                my ReadComment
            } else {
                break
            }
        }
    }

    
    method ReadTrue {} {
        my AssertNext t true
        my AssertNext r true
        my AssertNext u true
        my AssertNext e true
        return [Boolean new true]
    }

    
    method ReadFalse {} {
        my AssertNext f false
        my AssertNext a false
        my AssertNext l false
        my AssertNext s false
        my AssertNext e false
        return [Boolean new false]
    }

    
    method ReadNull {} {
        my AssertNext n null
        my AssertNext u null
        my AssertNext l null
        my AssertNext l null
        return [Null]
    }
    
    method ReadComment {} {

        switch -exact -- [my PeekChar 1][my PeekChar 2] {
            "//" {
                my ReadDoubleSolidusComment
            }
            "/*" {
                my ReadCStyleComment
            }
            default {
                throw {TYPES JSONparser} "Not a valid JSON comment: $jsonText"
            }
        }
    }
    
    method ReadCStyleComment {} {
        my AssertNext "/" "/*"
        my AssertNext "*" "/*"
        
        try {
            
            while {true} {
                set ch [my NextChar]
                
                switch -exact -- $ch {
                    "*" {
                        if { [my PeekChar] eq "/"} {
                            my AdvanceCursor
                            break
                        }
                    }
                    "/" {
                        if { [my PeekChar] eq "*"} {
                            throw {TYPES JSONparser} "Not a valid JSON comment: $jsonText, '/*' cannot be embedded in the comment at index $cursor." 
                        }
                    }

                } 
            }
            
        } on $EndOfTextException {} {
            throw {TYPES JSONparser} "not a valid JSON comment: $jsonText, expected */"
        }
    }

    
    method ReadDoubleSolidusComment {} {
        my AssertNext "/" "//"
        my AssertNext "/" "//"
        
        try {
            set ch [my NextChar]
            while { $ch ne "\r" && $ch ne "\n"} {
                set ch [my NextChar]
            }
        } on $EndOfTextException {} {}
    }
            
    method ReadArray {} {
        my AssertNext "\["
        my EatWhitespace

        if { [my PeekChar] eq "\]"} {
            my AdvanceCursor
            return [huddle list]
        }
            
        try {        
            while {true} {
                
                lappend result [my ParseNextData]
            
                my EatWhitespace
                    
                set ch [my NextChar]
        
                if {$ch eq "\]"} {
                    break
                } else {
                    if {$ch ne ","} {
                        throw {TYPES JSONparser} "Not a valid JSON array: '$jsonText' due to: '$ch' at index $cursor."
                    }
                    
                    my EatWhitespace
                }
            }
        } on $EndOfTextException {} {
            throw {TYPES JSONparser} "Not a valid JSON string: '$jsonText'"
        }
            
        return [List new {*}$result]
    }
        
    method ReadObject {} {

        my AssertNext "\{"
        my EatWhitespace

        if { [my PeekChar] eq "\}"} {
            my AdvanceCursor
            return [Dict new]
        }
        
        try {        
            while {true} {
                set key [my ReadStringLiteral]
            
                my EatWhitespace
                
                set ch [my NextChar]
        
                if { $ch ne ":"} {
                    throw {TYPES JSONparser} "Not a valid JSON object: '$jsonText' due to: '$ch' at index $cursor."
                }
        
                my EatWhitespace
        
                lappend result $key [my ParseNextData]
        
                my EatWhitespace
        
                set ch [my NextChar]
        
                if {$ch eq "\}"} {
                    break
                } else {
                    if {$ch ne ","} {
                        throw {TYPES JSONparser} "Not a valid JSON array: '$jsonText' due to: '$ch' at index $cursor."
                    }
                    
                    my EatWhitespace
                }
            }
        } on $EndOfTextException {} {
            throw {TYPES JSONparser} "Not a valid JSON string: '$jsonText'"
        }
                
        return [Dict new {*}$result]
    }
    
    
    method ReadNumber {} {
        regexp -start $cursor -- $numberRE $jsonText number
        my AdvanceCursor [string length $number]
        
        return [Number new $number]
    }    
    
    method ReadString {} {
        set string [my ReadStringLiteral]
        return [String new $string]
    }
            

    method ReadStringLiteral {} {
        
        my AssertNext "\""
        
        set result ""
        try {
            while {true} {
                set ch [my NextChar]
                
                if {$ch eq "\""} break
                
                if {$ch eq "\\"} {
                    set ch [my NextChar]
                    switch -exact -- $ch {
                        "b" {
                            set ch "\b"
                        }
                        "r" {
                            set ch "\r"
                        }
                        "n" {
                            set ch "\n"
                        }
                        "f" {
                            set ch "\f"
                        }
                        "t" {
                            set ch "\t"
                        }
                        "u" {
                            set ch [format "%c" 0x[my NextChar][my NextChar][my NextChar][my NextChar]]
                        }
                        "\"" {}
                        "/"  {}
                        "\\" {}
                        default {
                            throw {TYPES JSONparser} "Not a valid escaped JSON character: '$ch' in $jsonText"
                        }
                    }
                }
                append result $ch
            }
        } on $EndOfTextException {} {
            throw {TYPES JSONparser} "Not a valid JSON string: '$jsonText'"
        }

        return $result
    }

}    
    
namespace eval ::types {
    JSON_2_typedObj create json_2_typedObj
    namespace export parse_json
}

proc ::types::parse_json {json} {
    return [json_2_typedObj parse $json]
}
