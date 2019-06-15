package provide selenium::utils::selectors 0.1

namespace eval ::selenium::utils::selectors {
    namespace export *
    
    # http:#dev.w3.org/csswg/cssom/#serialize-an-identifier
	proc escape_string_in_css {value} {
		set length [string length $value]
		set result {}
            
		set firstchar [string index $value 0]
            
		for {set index 0} {$index < $length} {incr index} {
                
			set char [string index $value $index]
                
			# Note: there’s no need to special-case astral symbols, surrogate
			# pairs, or lone surrogates.

				# If the character is NULL (U+0000), then throw an invalid character error.
				if {$char eq "\u0000"} {
					error "Invalid character: the input contains U+0000."
				}

                # If the character is in the range [\1-\1F] (U+0001 to U+001F) or is U+007F, 
                # or the character is the first character and is in the range [0-9] (U+0030 to U+0039),
                # or the character is the second character and is in the range [0-9] (U+0030 to U+0039) and the 
                # first character is a `-` (U+002D)
				if {
					($char >= "\u0001" && $char <= "\u001F") || $char eq "\u007F" ||
					($index == 0 && $char >= "\u0030" && $char <= "\u0039") ||
					($index == 1 && $char >= "\u0030" && $char <= "\u0039" && $firstchar eq "\u002D")
				} {
                    # then we create create a string of "\", followed by the Unicode code point as the smallest 
                    # possible number of hexadecimal digits in the range 0-9 a-f to represent the code point in base 16, 
                    # followed by a single SPACE
					# See: http://dev.w3.org/csswg/cssom/#escape-a-character-as-code-point
					append result "\\[format %x [scan $char %c]] "
					continue
				}

				# If the character is not handled by one of the above rules and is
				# greater than or equal to U+0080, is `-` (U+002D) or `_` (U+005F), or
				# is in one of the ranges [0-9] (U+0030 to U+0039), [A-Z] (U+0041 to
				# U+005A), or [a-z] (U+0061 to U+007A)
				if {
					$char >= "\u0080" ||
					$char eq "\u002D" ||
					$char eq "\u005F" ||
					$char >= "\u0030" && $char <= "\u0039" ||
					$char >= "\u0041" && $char <= "\u005A" ||
					$char >= "\u0061" && $char <= "\u007A"
				} {
					# then append the character itself
					append result $char
					continue
				}

				# Otherwise, the escaped character.
				# http:#dev.w3.org/csswg/cssom/#escape-a-character
				append result "\\$char"

        }
        
        return $result
    }
    
    proc escape_string_in_xpath {value} {
        if {[string first \" $value] != -1 && [string first ' $value] != -1} {
            set substrings [split $value \"]
            set result {concat("}
                
            append result [join $substrings {", '"', "}]
            append result {")}
            
            return $result
        }
        
        if {[string first \" $value] != -1} {
            return "'$value'"
        }

        return "\"$value\""

    }
}
