namespace eval ::selenium {

	variable StatusCache
		
	array set StatusCache { 
		
		0 UNCACHED
		1 IDLE
		2 CHECKING
		3 DOWNLOADING
		4 UPDATE_READY
		5 OBSOLETE
	}
}
