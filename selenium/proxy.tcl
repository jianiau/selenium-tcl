namespace eval ::selenium {
    # Set of possible types of proxy.

    # Each proxy type has 2 properties:
    # 'ff_value' is value of Firefox profile preference,
    # 'string' is id of proxy type.

    variable ProxyType
    
    set ProxyType(DIRECT) [dict create ff_value 0 string DIRECT]
    set ProxyType(MANUAL) [dict create ff_value 1 string MANUAL]
    set ProxyType(PAC) [dict create ff_value 2 string PAC]
    set ProxyType(RESERVED_1) [dict create ff_value 3 string RESERVED_1]
    set ProxyType(AUTODETECT) [dict create ff_value 4 string AUTODETECT]
    set ProxyType(SYSTEM) [dict create ff_value 5 string SYSTEM]
    set ProxyType(UNSPECIFIED) [dict create ff_value 6 string UNSPECIFIED]
}
