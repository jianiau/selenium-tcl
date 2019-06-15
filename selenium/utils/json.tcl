package provide selenium::utils::json 0.1

namespace eval selenium::utils::json {
    namespace export compile_to_json json_to_tcl
	proc compile_to_json {spec data} {
		while [llength $spec] {
			set type [lindex $spec 0]
			set spec [lrange $spec 1 end]
	
			switch -- $type {
				dict {
					if {![llength $spec]} {
						lappend spec * string
					}
					
					set json {}
					foreach {key value} $data {
						foreach {matching_key subspec} $spec {
							if {[string match $matching_key $key]} {
								lappend json [subst {"$key":[compile_to_json $subspec $value]}]
								break
							}
						}
					}
					return "{[join $json ,]}"
				}
				list {
					if {![llength $spec]} {
						set spec string
					} else {
						set spec [lindex $spec 0]
					}
					
					set json {}
					foreach list_item $data {
						lappend json [compile_to_json $spec $list_item]
					}
					return "\[[join $json ,]\]"
				}
				string {
                    set data [string map {
                        \n \\n
                        \t \\t
                        \r \\r
                        \b \\b
                        \f \\f
                        \\ \\\\
                        \" \\\"
                    } $data]
                    return "\"$data\""
				}
				number {
					if {[string is double -strict $data]} {
						return $data
					} else {
						error "Bad number: $data"
					}
				}
                bool -
				boolean {
					if $data {
						return true
					} else {
						return false
					}
				}
				null {
					if {$data eq ""} {
						return null
					} else {
						error "Data must be an empty string: '$data'"
					}
				}
				json {
					return $data
				}
				default {error "Invalid type: '$type'"}
			}
		}
	}
    
    oo::class create JsonParser {
        
        variable cursor jsonToParse EndOfTextException numberRE
        
        constructor {} {
            
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
            set jsonToParse $json_to_parse
            
            my parseNextData
        }
            
        method peekChar { {increment 1} } {
            return [string index $jsonToParse [expr $cursor+$increment]]
        }

        method advanceCursor { {increment 1} } {
            incr cursor $increment
        }
        
        method nextChar {} {
            if {$cursor + 1 < [string length $jsonToParse] } {
                incr cursor
                return [string index $jsonToParse $cursor]    
            } else {
                return -code $EndOfTextException
            }
        }
    
        method assertNext {ch {target ""}} {
            incr cursor
            
            if {[string index $jsonToParse $cursor] != $ch} {
                if {$target == ""} {
                    set target $ch
                }
                throw JSONparser "Trying to read the string $target at index $cursor."
            }
        }
    
    
        method parseNextData {} {
            
            my eatWhitespace
            
            set ch [my peekChar]
            
            if {$ch eq ""} {
                throw JSONparser {Nothing to read}
            }
            
                        
            switch -exact -- $ch {
                "\{" {
                    return [my readObject]
                } 
                "\[" {
                    return [my readArray]
                } 
                "\"" {
                    return [my readString]
                } 

                "t" {
                    return [my readTrue]
                }
                "f" {
                    return [my readFalse]
                }
                "n" {
                    return [my readNull]
                } 
                "/" {
                    my readComment
                    return [my parseNextData]
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
                    return [my readNumber]
                } 
                default {
                    throw JSONparser "Input is not valid JSON: '$jsonToParse'" 
                }
            }
        }
        
        method eatWhitespace {} {

            while {true} {
                set ch [my peekChar]
                
                if [string is space -strict $ch] {
                    my advanceCursor
                } elseif {$ch eq "/"} {
                    my readComment
                } else {
                    break
                }
            }
        }

        
        method readTrue {} {
            my assertNext t true
            my assertNext r true
            my assertNext u true
            my assertNext e true
            return "true"
        }
    
        
        method readFalse {} {
            my assertNext f false
            my assertNext a false
            my assertNext l false
            my assertNext s false
            my assertNext e false
            return "false"
        }
    
        
        method readNull {} {
            my assertNext n null
            my assertNext u null
            my assertNext l null
            my assertNext l null
            return ""
        }
        
        method readComment {} {

            switch -exact -- [my peekChar 1][my peekChar 2] {
                "//" {
                    my readDoubleSolidusComment
                }
                "/*" {
                    my readCStyleComment
                }
                default {
                    throw JSONparser "Not a valid JSON comment: $jsonToParse"
                }
            }
        }
        
        method readCStyleComment {} {
            my assertNext "/" "/*"
            my assertNext "*" "/*"
            
            try {
                
                while {true} {
                    set ch [my nextChar]
                    
                    switch -exact -- $ch {
                        "*" {
                            if { [my peekChar] eq "/"} {
                                my advanceCursor
                                break
                            }
                        }
                        "/" {
                            if { [my peekChar] eq "*"} {
                                throw JSONparser "Not a valid JSON comment: $jsonToParse, '/*' cannot be embedded in the comment at index $cursor." 
                            }
                        }

                    } 
                }
                
            } on $EndOfTextException {} {
                throw JSONparser "not a valid JSON comment: $jsonToParse, expected */"
            }
        }

        
        method readDoubleSolidusComment {} {
            my assertNext "/" "//"
            my assertNext "/" "//"
            
            try {
                set ch [my nextChar]
                while { $ch ne "\r" && $ch ne "\n"} {
                    set ch [my nextChar]
                }
            } on $EndOfTextException {} {}
        }
                
        method readArray {} {
            my assertNext "\["
            my eatWhitespace

            if { [my peekChar] eq "\]"} {
                my advanceCursor
                return [list]
            }

            set result [list]
            
            try {        
                while {true} {
                    
                    lappend result [my parseNextData]
                
                    my eatWhitespace
                        
                    set ch [my nextChar]
            
                    if {$ch eq "\]"} {
                        break
                    } else {
                        if {$ch ne ","} {
                            throw JSONparser "Not a valid JSON array: '$jsonToParse' due to: '$ch' at index $cursor."
                        }
                        
                        my eatWhitespace
                    }
                }
            } on $EndOfTextException {} {
                throw JSONparser "Not a valid JSON string: '$jsonToParse'"
            }
                
            return $result
        }
            
        
        
        method readObject {} {

            my assertNext "\{"
            my eatWhitespace

            if { [my peekChar] eq "\}"} {
                my advanceCursor
                return [dict create]
            }
            
            set result [dict create]
            
            try {        
                while {true} {
                    set key [my readString]
                
                    my eatWhitespace
                    
                    set ch [my nextChar]
            
                    if { $ch ne ":"} {
                        throw JSONparser "Not a valid JSON object: '$jsonToParse' due to: '$ch' at index $cursor."
                    }
            
                    my eatWhitespace
            
                    dict set result $key [my parseNextData]
            
                    my eatWhitespace
            
                    set ch [my nextChar]
            
                    if {$ch eq "\}"} {
                        break
                    } else {
                        if {$ch ne ","} {
                            throw JSONparser "Not a valid JSON array: '$jsonToParse' due to: '$ch' at index $cursor."
                        }
                        
                        my eatWhitespace
                    }
                }
            } on $EndOfTextException {} {
                throw JSONparser "Not a valid JSON string: '$jsonToParse'"
            }
                    
            return $result
        }
        
        
        method readNumber {} {
            regexp -start $cursor -- $numberRE $jsonToParse number
            my advanceCursor [string length $number]
            
            return $number
        }    
        
        method readString {} {
            
            my assertNext "\""
            
            set result ""
            try {
                while {true} {
                    set ch [my nextChar]
                    
                    if {$ch eq "\""} break
                    
                    if {$ch eq "\\"} {
                        set ch [my nextChar]
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
                                set ch [format "%c" 0x[my nextChar][my nextChar][my nextChar][my nextChar]]
                            }
                            "\"" {}
                            "/"  {}
                            "\\" {}
                            default {
                                throw JSONparser "Not a valid escaped JSON character: '$ch' in $jsonToParse"
                            }
                        }
                    }
                    append result $ch
                }
            } on $EndOfTextException {} {
                throw JSONparser "Not a valid JSON string: '$jsonToParse'"
            }

            return $result
        }
    
    }    
    
    JsonParser create json_parser
    
    proc json_to_tcl {data} {
        return [json_parser parse $data]
    }
    
}
