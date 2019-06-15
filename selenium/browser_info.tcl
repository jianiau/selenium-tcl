package provide browser_info 0.1

namespace eval ::browser_info {

    array set WINDOWS_LOCALE {
        0436 af_ZA 
        041c sq_AL 
        0484 gsw_FR
        045e am_ET 
        0401 ar_SA 
        0801 ar_IQ 
        0c01 ar_EG 
        1001 ar_LY 
        1401 ar_DZ 
        1801 ar_MA 
        1c01 ar_TN 
        2001 ar_OM 
        2401 ar_YE 
        2801 ar_SY 
        2c01 ar_JO 
        3001 ar_LB 
        3401 ar_KW 
        3801 ar_AE 
        3c01 ar_BH 
        4001 ar_QA 
        042b hy_AM 
        044d as_IN 
        042c az_AZ 
        082c az_AZ 
        046d ba_RU 
        042d eu_ES 
        0423 be_BY 
        0445 bn_IN 
        201a bs_BA 
        141a bs_BA 
        047e br_FR 
        0402 bg_BG 
        0403 ca_ES 
        0004 zh_CHS
        0404 zh_TW 
        0804 zh_CN 
        0c04 zh_HK 
        1004 zh_SG 
        1404 zh_MO 
        7c04 zh_CHT
        0483 co_FR 
        041a hr_HR 
        101a hr_BA 
        0405 cs_CZ 
        0406 da_DK 
        048c gbz_AF
        0465 div_MV
        0413 nl_NL 
        0813 nl_BE 
        0409 en_US 
        0809 en_GB 
        0c09 en_AU 
        1009 en_CA 
        1409 en_NZ 
        1809 en_IE 
        1c09 en_ZA 
        2009 en_JA 
        2409 en_CB 
        2809 en_BZ 
        2c09 en_TT 
        3009 en_ZW 
        3409 en_PH 
        4009 en_IN 
        4409 en_MY 
        4809 en_IN 
        0425 et_EE 
        0438 fo_FO 
        0464 fil_PH
        040b fi_FI 
        040c fr_FR 
        080c fr_BE 
        0c0c fr_CA 
        100c fr_CH 
        140c fr_LU 
        180c fr_MC 
        0462 fy_NL 
        0456 gl_ES 
        0437 ka_GE 
        0407 de_DE 
        0807 de_CH 
        0c07 de_AT 
        1007 de_LU 
        1407 de_LI 
        0408 el_GR 
        046f kl_GL 
        0447 gu_IN 
        0468 ha_NG 
        040d he_IL 
        0439 hi_IN 
        040e hu_HU 
        040f is_IS 
        0421 id_ID 
        045d iu_CA 
        085d iu_CA 
        083c ga_IE 
        0410 it_IT 
        0810 it_CH 
        0411 ja_JP 
        044b kn_IN 
        043f kk_KZ 
        0453 kh_KH 
        0486 qut_GT
        0487 rw_RW 
        0457 kok_IN
        0412 ko_KR 
        0440 ky_KG 
        0454 lo_LA 
        0426 lv_LV 
        0427 lt_LT 
        082e dsb_DE
        046e lb_LU 
        042f mk_MK 
        043e ms_MY 
        083e ms_BN 
        044c ml_IN 
        043a mt_MT 
        0481 mi_NZ 
        047a arn_CL
        044e mr_IN 
        047c moh_CA
        0450 mn_MN 
        0850 mn_CN 
        0461 ne_NP 
        0414 nb_NO 
        0814 nn_NO 
        0482 oc_FR 
        0448 or_IN 
        0463 ps_AF 
        0429 fa_IR 
        0415 pl_PL 
        0416 pt_BR 
        0816 pt_PT 
        0446 pa_IN 
        046b quz_BO
        086b quz_EC
        0c6b quz_PE
        0418 ro_RO 
        0417 rm_CH 
        0419 ru_RU 
        243b smn_FI
        103b smj_NO
        143b smj_SE
        043b se_NO 
        083b se_SE 
        0c3b se_FI 
        203b sms_FI
        183b sma_NO
        1c3b sma_SE
        044f sa_IN 
        0c1a sr_SP 
        1c1a sr_BA 
        081a sr_SP 
        181a sr_BA 
        045b si_LK 
        046c ns_ZA 
        0432 tn_ZA 
        041b sk_SK 
        0424 sl_SI 
        040a es_ES 
        080a es_MX 
        0c0a es_ES 
        100a es_GT 
        140a es_CR 
        180a es_PA 
        1c0a es_DO 
        200a es_VE 
        240a es_CO 
        280a es_PE 
        2c0a es_AR 
        300a es_EC 
        340a es_CL 
        380a es_UR 
        3c0a es_PY 
        400a es_BO 
        440a es_SV 
        480a es_HN 
        4c0a es_NI 
        500a es_PR 
        540a es_US 
        0441 sw_KE 
        041d sv_SE 
        081d sv_FI 
        045a syr_SY
        0428 tg_TJ 
        085f tmz_DZ
        0449 ta_IN 
        0444 tt_RU 
        044a te_IN 
        041e th_TH 
        0851 bo_BT 
        0451 bo_CN 
        041f tr_TR 
        0442 tk_TM 
        0480 ug_CN 
        0422 uk_UA 
        042e wen_DE
        0420 ur_PK 
        0820 ur_IN 
        0443 uz_UZ 
        0843 uz_UZ 
        042a vi_VN 
        0452 cy_GB 
        0488 wo_SN 
        0434 xh_ZA 
        0485 sah_RU
        0478 ii_CN 
        046a yo_NG 
        0435 zu_ZA 
    }
    
    
    variable LANGUAGE_NAME   
    array set LANGUAGE_NAME {
        en English
        es Spanish
        de German
        fr French
        it Italian
        pt Portuguese
        sv Swedish
        da Danish
        nb Norwegian
        nn Norwegian
        ro Romanian
    }
                
    array set PROGRAM_FILES {
        English {{C:\Program Files} {C:\Program Files (x86)}}
        German {{C:\Programme} {C:\Programme (x86)}}
        Spanish {{C:\Archivos de programa} {C:\Archivos de programa (x86)}}
        French {{C:\Programmes} {C:\Programmes (x86)}}
        Italian {{C:\Programmi} {C:\Programmi (x86)}}
        Portuguese {{C:\Arquivos de Programas} {C:\Arquivos de Programas (x86)}}
        Swedish {{C:\Program} {C:\Program (x86)}}
        Danish {{C:\Programmer} {C:\Programmer (x86)}}
        Norwegian {{C:\Programfiler} {C:\Programfiler (x86)}}
        Romanian {{C:\Fisiere Program} {C:\Fisiere Program (x86)}}
    }
    
    variable DEFAULT_BROWSER_PATH_ON_MAC
    
    array set DEFAULT_BROWSER_PATH_ON_MAC {
        firefox {/Applications/Firefox.app/Contents/MacOS/firefox-bin}
        chrome {/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}
        safari {/Applications/Safari.app/Contents/MacOS/Safari}
        opera {/Applications/Opera.app/Contents/MacOS/Opera}   
    }
    
    variable BINARY_DIRECTORY_ON_WINDOWS
    
    array set BINARY_DIRECTORY_ON_WINDOWS {
        ie {Internet Explorer}
        firefox {Mozilla Firefox}
        chrome {Google\Chrome\Application}        
        opera {Opera}
    }
    
    variable BINARY_NAME
    
    array set BINARY_NAME {
        windows {
            ie iexplore.exe
            firefox firefox.exe
            chrome chrome.exe
            opera opera.exe
        }
        linux {
            firefox firefox 
            chrome google-chrome 
            opera opera
        }
    }
    
    # https://helgeklein.com/blog/2010/08/how-the-app-paths-registry-key-makes-windows-both-faster-and-safer/
    # https://msdn.microsoft.com/en-us/library/windows/desktop/ee872121%28v=vs.85%29.aspx
    
    variable BROWSER_PATH_IN_WINDOWS_REGISTRY
    
    # The arrays for the windows registry has this format: 
    #   browser_name: 
    #       subpath_of_keys 
    #       pattern_of_last_key 
    #       key_value
    
    array set BROWSER_PATH_IN_WINDOWS_REGISTRY {
        ie {{HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\IEXPLORE.EXE} {} {}}
        firefox {
            {HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe} {} {}
            {HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe} {} {}}
        chrome {
            {HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe} {} {}
            {HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\chrome.exe} {} {}}
        opera {
            {HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\App Paths\Opera.exe} {} {}
            {HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\Opera.exe} {} {}}
    }
    
    # Another posibles keys to find the path of firefox:
    #  HKEY_LOCAL_MACHINE\SOFTWARE\Classes\FirefoxHTML\shell\open\command
    #  HKEY_CURRENT_USER\SOFTWARE\Classes\FirefoxHTML\shell\open\command
    #  HKEY_LOCAL_MACHINE\SOFTWARE\Classes\Applications\firefox.exe\shell\open\command
    #  HKEY_CURRENT_USER\SOFTWARE\Classes\Applications\firefox.exe\shell\open\command
    
    # http://stackoverflow.com/questions/4212002/how-to-find-out-from-the-windows-registry-where-ie-is-installed
    # I can find out where Firefox is installed as follows; query this key to get the current version:
    #   HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla\Mozilla Firefox
    #      CurrentVersion
    # ... then query this key to get the installed path (where "nnn" is the version number obtained above):
    #   HKEY_LOCAL_MACHINE\SOFTWARE\Mozilla\Mozilla Firefox\nnn\Main
    #      Install Directory

    
    variable BROWSER_VERSION_IN_WINDOWS_REGISTRY
    
    # http://automationoverflow.blogspot.com.es/2013/08/find-installed-browser-version-from.html
    
    array set BROWSER_VERSION_IN_WINDOWS_REGISTRY {
        ie {
            {HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer} {} svcVersion
            {HKEY_LOCAL_MACHINE\Software\Microsoft\Internet Explorer} {} Version
        }
        opera {
            {HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall} {[Oo]pera *} DisplayVersion
            {HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall} {[Oo]pera *} DisplayVersion
        }
        chrome {
            {HKEY_CURRENT_USER\Software\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome} {} DisplayVersion
            {HKEY_LOCAL_MACHINE\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Google Chrome} {} DisplayVersion
            HKEY_CLASSES_ROOT\\Wow6432Node\\CLSID\\{5C65F4B0-3651-4514-B207-D10CB699B14B}\\LocalServer32 {} {}
        }
        firefox {                    
            {HKEY_CURRENT_USER\Software\Mozilla\Mozilla Firefox} {} CurrentVersion
            {HKEY_LOCAL_MACHINE\Software\Mozilla\Mozilla Firefox} {} CurrentVersion
            {HKEY_LOCAL_MACHINE\Software\Wow6432Node\Mozilla\Mozilla Firefox} {} CurrentVersion
        }
    }
        
    variable COMMAND_TO_GET_BROWSER_VERSION
    array set COMMAND_TO_GET_BROWSER_VERSION {
        firefox {firefox -v}
        chrome {google-chrome --version}
        opera {opera -version}
    }
    
    
    namespace export firefox ie chrome opera
    
    
    oo::class create browser_info {
        variable browser_name path_to_browser browser_version WINDOWS_LOCALE LANGUAGE_NAME PROGRAM_FILES COMMAND_TO_GET_BROWSER_VERSION DEFAULT_BROWSER_PATH_ON_MAC BROWSER_PATH_IN_WINDOWS_REGISTRY BROWSER_VERSION_IN_WINDOWS_REGISTRY BINARY_NAME BINARY_DIRECTORY_ON_WINDOWS
        
        constructor {browserName} {
            set browser_name $browserName
            
            foreach varname [info class variables [self class]] {

                if [string is upper [string index $varname 0]] {
                    # We avoid hard-coding the exact namespace
                    set namespace_of_browser_info [namespace qualifiers [info object class [self]]]
                    namespace upvar $namespace_of_browser_info $varname [self namespace]::$varname
                }
            }
            
        }
                
        method default_program_files_on_windows {} {
   
            set locale_code [my get_windows_locale_ID]
    
            if {$locale_code eq ""} {
                set language_code [lindex [split $locale_code "_"] 0]
            } else {
                set language_code "en"
            }
            
            set language $LANGUAGE_NAME($language_code)
            return $PROGRAM_FILES($language)
        }
        
        
        method default_windows_location_of_browser {} {
            
            set directory_of_program_files [list]
        
            set default_program_files [my default_program_files_on_windows]
        
        
            if {[info exists ::env(PROGRAMFILES)]} {
                lappend directory_of_program_files $::env(PROGRAMFILES)
            } else {
                lappend directory_of_program_files [lindex $default_program_files 0]
            }
    
            if {[info exists ::env(PROGRAMFILES(X86)]} {
                lappend directory_of_program_files $::env(PROGRAMFILES(X86)
            } else {
                lappend directory_of_program_files [lindex $default_program_files 1]
            }
    
            set browser_subpath [file join $BINARY_DIRECTORY_ON_WINDOWS($browser_name) [dict get $BINARY_NAME(windows) $browser_name]]
            foreach directory $directory_of_program_files {
                set binary_path [file join $directory $browser_subpath]
            
                if {[file isfile $binary_path] && [file executable $binary_path]} {
                    return $binary_path
                }
    
            }
            
            return {}
        }      
        
            
        method get_windows_locale_ID {} {
            package require registry
            
            set locale_subkey [string tolower [registry get {HKEY_LOCAL_MACHINE\system\controlset001\control\nls\language} Installlanguage]]
            
            if {[info exists WINDOWS_LOCALE($locale_subkey)]} {
                return $WINDOWS_LOCALE($locale_subkey)
            } else {
                return ""
            }
        }
        
        method which {executable} {
            foreach path [split $::env(PATH) $::tcl_platform(pathSeparator)] {
                set exe [file join $path $executable]
                if {[file isfile $exe] && [file executable $exe]} {
                    return $exe
                }
            }
    
            return {}
        }
        
        method first_value_found_in_windows_registry {data_of_paths} {
            package require registry
            
            set value_found ""
            foreach {subpath_of_keys pattern_of_last_key key_value} $data_of_paths {
                if {$pattern_of_last_key ne ""} {
                    set list_of_subkeys [registry keys $subpath_of_keys $pattern_of_last_key]
                    if {[llength $list_of_subkeys] != 0} {
                        set key_name "$subpath_of_keys\\[lindex $list_of_subkeys 0]"
                    } else {
                        continue
                    }
                } else {
                    set key_name $subpath_of_keys
                }
                
                try {
                    set value_found [registry get $key_name $key_value]
                    break
                } on error {} {
    
                }
            }
            
            return $value_found
        }
                
        method browser_path_in_windows_registry {} {
            set browser_command [my first_value_found_in_windows_registry $BROWSER_PATH_IN_WINDOWS_REGISTRY($browser_name)]
            return $browser_command
        }
        
        method browser_version_in_windows_registry {} {
            set browser_version [my get_version_from_text [my first_value_found_in_windows_registry $BROWSER_VERSION_IN_WINDOWS_REGISTRY($browser_name)]]
            return $browser_version
        }
                
        method get_path {} {
            # Returns the path to the browser binary.
            
            if {[info exists path_to_browser]} {
                return $path_to_browser
            }
                        
            if {$::tcl_platform(platform) eq "windows"} {
                set path_to_browser [string trim [my browser_path_in_windows_registry] \"]
                if {$path_to_browser eq ""} {
                    set path_to_browser [my default_windows_location_of_browser]
                }
            } elseif {$::tcl_platform(os) eq "Linux"} {                
                set path_to_browser [my which [dict get $BINARY_NAME(linux) $browser_name]]
            } elseif {$::tcl_platform(os) eq "MacOS" || $::tcl_platform(os) eq "Darwin"} {
                set path_to_browser $DEFAULT_BROWSER_PATH_ON_MAC($browser_name)
            } 
    
            return $path_to_browser
        }
        
        method get_version {} {
            # Returns the version of the browser.
            
            if {[info exists browser_version]} {
                return $browser_version
            }
            
            if {$::tcl_platform(platform) eq "windows"} {                
                return [my browser_version_in_windows_registry]
            } elseif {$::tcl_platform(os) eq "Linux"} {   

                catch "exec $COMMAND_TO_GET_BROWSER_VERSION($browser_name)" output
    
                foreach line [split $output "\n"] {
                    if {[set browser_version [my get_version_from_text $line]] ne ""} break
                }
            } elseif {$::tcl_platform(os) eq "MacOS" || $::tcl_platform(os) eq "Darwin"} {
    
            }
    
            return $browser_version
        }
        
        method get_version_from_text {text} {
            if {[regexp {(\d+\.\d+(?:\.\d+)*)} $text -> browser_version]} {
                return $browser_version
            } 
            return ""
        }
    
    }
    
    oo::class create Firefox {       
        superclass browser_info
        
        constructor {} {
            next firefox
        }   
    }
    
    oo::class create IE {
        superclass browser_info 
        
        constructor {} {
            next ie
        }
    }
    
    oo::class create Chrome {
        superclass browser_info
        
        constructor {} {
            next chrome
        }
    }
    
    oo::class create Opera {
        superclass browser_info
        
        constructor {} {
            next opera
        }
    }
    
    Firefox create firefox
    IE create ie
    Chrome create chrome
    Opera create opera
    
}
