package provide selenium::utils::url_codification 0.1

namespace eval ::selenium::utils::url_codification {
    namespace export url_encode url_decode
    
    variable alphanumeric -a-zA-Z0-9._~
    variable map
    for {set i 0} {$i <= 256} {incr i} { 
            set c [format %c $i]
            if {![string match \[$alphanumeric\] $c]} {
                    set map($c) %[format %.2x $i]
            }
    }
    # These characteres are handled specially
    array set map { " " + \n %0d%0a }
		
	proc url_encode {str} {
        variable map
        variable alphanumeric

        # The spec says: "non-alphanumeric characters are replaced by '%HH'"
        # 1 leave alphanumerics characters alone
        # 2 Convert every other character to an array lookup
        # 3 Escape constructs that are "special" to the tcl parser
        # 4 "subst" the result, doing all the array substitutions

        regsub -all \[^$alphanumeric\] $str {$map(&)} str
        # This quotes cases like $map([) or $map($) => $map(\[) ...
        regsub -all {[][{})\\]\)} $str {\\&} str
        return [subst -nocommand $str]
	}
	
	proc utf8 {hex} {
		set hex [string map {% {}} $hex]
		encoding convertfrom utf-8 [binary decode hex $hex]
	}

	proc url_decode {str} {
		# rewrite "+" back to space
		# protect \ from quoting another '\'
		set str [string map [list + { } "\\" "\\\\"] $str]

		# Replace UTF-8 sequences with calls to the utf8 decode proc...
		regsub -all {(%[0-9A-Fa-f0-9]{2})+} $str {[utf8 \0]} str
    
		return [subst -novar -noback $str]
	}
}
