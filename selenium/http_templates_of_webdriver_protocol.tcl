namespace eval ::selenium {
	
	variable HTTP_TEMPLATES_OF_WEBDRIVER_PROTOCOL
	
	set json_spec(COOKIE) {dict 
                                name string 
                                value string 
                                path string 
                                domain string 
                                secure boolean 
                                httpOnly boolean 
                                expiry number}
	
	set json_spec(CAPABILITIES) { dict 
                                    browserName string 
                                    version string
                                    platform string 
                                    javascriptEnabled boolean 
                                    takesScreenshot boolean 
                                    handlesAlerts boolean 
                                    databaseEnabled boolean 
                                    locationContextEnabled boolean 
                                    applicationCacheEnabled boolean 
                                    browserConnectionEnabled boolean 
                                    cssSelectorsEnabled boolean 
                                    webStorageEnabled boolean 
                                    rotatable boolean 
                                    acceptSslCerts boolean 
                                    nativeEvents boolean
                                    marionette boolean
                                    moz:firefoxOptions {dict 
                                        binary string
                                        profile string
                                        args list
                                    }
                                    chromeOptions {dict 
                                        args list
                                        binary string
                                        extensions list
                                        localState dict
                                        prefs dict
                                        detach boolean
                                        debuggerAddress string
                                        excludeSwitches list
                                        minidumpPath string
                                        mobileEmulation dict
                                        perfLoggingPrefs dict}
                                    proxy {dict 
                                        proxyType string 
                                        proxyAutoconfigUrl string 
                                        ftpProxy string 
                                        httpProxy string 
                                        httpProxyPort number
                                        sslProxy string 
                                        socksProxy string 
                                        socksUsername string 
                                        socksPassword string 
                                        noProxy string}
                                     * string}
												
	
	set HTTP_TEMPLATES_OF_WEBDRIVER_PROTOCOL [subst -nobackslashes -nocommands {
		"$Command(STATUS)" {GET /status {} {}}
		"$Command(NEW_SESSION)" {POST /session {} {dict desiredCapabilities {$json_spec(CAPABILITIES)}  requiredCapabilities {$json_spec(CAPABILITIES)}}}
		"$Command(GET_ALL_SESSIONS)" {GET /sessions {} {}}
		"$Command(QUIT)" {DELETE /session/:sessionId {sessionId} {}}
		"$Command(GET_CURRENT_WINDOW_HANDLE)" {GET /session/:sessionId/window_handle {sessionId} {}}
		"$Command(GET_WINDOW_HANDLES)" {GET /session/:sessionId/window_handles {sessionId} {}}
		"$Command(GET)" {POST /session/:sessionId/url {sessionId} {dict url string}}
		"$Command(GO_FORWARD)" {POST /session/:sessionId/forward {sessionId} {}}
		"$Command(GO_BACK)" {POST /session/:sessionId/back {sessionId} {}}
		"$Command(REFRESH)" {POST /session/:sessionId/refresh {sessionId} {}}
		"$Command(EXECUTE_SCRIPT)" {POST /session/:sessionId/execute {sessionId} {dict script string args {list json}}}
		"$Command(GET_CURRENT_URL)" {GET /session/:sessionId/url {sessionId} {}}
		"$Command(GET_TITLE)" {GET /session/:sessionId/title {sessionId} {}}
		"$Command(GET_PAGE_SOURCE)" {GET /session/:sessionId/source {sessionId} {}}
		"$Command(SCREENSHOT)" {GET /session/:sessionId/screenshot {sessionId} {}}
		"$Command(ELEMENT_SCREENSHOT)" {GET /session/:sessionId/element/:id/screenshot {sessionId id}}
		"$Command(FIND_ELEMENT)" {POST /session/:sessionId/element {sessionId} {dict using string value string}}
		"$Command(FIND_ELEMENTS)" {POST /session/:sessionId/elements {sessionId} {dict using string value string}}
		"$Command(GET_ACTIVE_ELEMENT)" {POST /session/:sessionId/element/active {sessionId} {}}
		"$Command(FIND_CHILD_ELEMENT)" {POST /session/:sessionId/element/:id/element {sessionId id} {dict using string value string}}
		"$Command(FIND_CHILD_ELEMENTS)" {POST /session/:sessionId/element/:id/elements {sessionId id} {dict using string value string}}
		"$Command(CLICK_ELEMENT)" {POST /session/:sessionId/element/:id/click {sessionId id}}
		"$Command(CLEAR_ELEMENT)" {POST /session/:sessionId/element/:id/clear {sessionId id}}
		"$Command(SUBMIT_ELEMENT)" {POST /session/:sessionId/element/:id/submit {sessionId id}}
		"$Command(GET_ELEMENT_TEXT)" {GET /session/:sessionId/element/:id/text {sessionId id}}
		"$Command(SEND_KEYS_TO_ELEMENT)" {POST /session/:sessionId/element/:id/value {sessionId id} {dict value list text string}}
		"$Command(TYPEWRITE)" {POST /session/:sessionId/keys {sessionId} {dict value list}}
		"$Command(UPLOAD_FILE)" {POST /session/:sessionId/file {sessionId} {}}
		"$Command(GET_ELEMENT_VALUE)" {GET /session/:sessionId/element/:id/value {sessionId id}}
		"$Command(GET_ELEMENT_TAG_NAME)" {GET /session/:sessionId/element/:id/name {sessionId id}}
		"$Command(IS_ELEMENT_SELECTED)" {GET /session/:sessionId/element/:id/selected {sessionId id}}
		"$Command(SET_ELEMENT_SELECTED)" {POST /session/:sessionId/element/:id/selected {sessionId id}}
		"$Command(IS_ELEMENT_ENABLED)" {GET /session/:sessionId/element/:id/enabled {sessionId id}}
		"$Command(IS_ELEMENT_DISPLAYED)" {GET /session/:sessionId/element/:id/displayed {sessionId id}}
		"$Command(GET_ELEMENT_LOCATION)" {GET /session/:sessionId/element/:id/location {sessionId id}}
		"$Command(GET_ELEMENT_LOCATION_ONCE_SCROLLED_INTO_VIEW)" {GET /session/:sessionId/element/:id/location_in_view {sessionId id}}
		"$Command(GET_ELEMENT_SIZE)" {GET /session/:sessionId/element/:id/size {sessionId id}}
		"$Command(GET_ELEMENT_RECT)" {GET /session/:sessionId/element/:id/rect {sessionId id}}
		"$Command(GET_ELEMENT_ATTRIBUTE)" {GET /session/:sessionId/element/:id/attribute/:name {sessionId id name}}
        "$Command(GET_ELEMENT_PROPERTY)" {GET /session/:sessionId/element/:id/property/:name {sessionId id name}}
		"$Command(ELEMENT_EQUALS)" {GET /session/:sessionId/element/:id/equals/:other {sessionId id other}}
		"$Command(GET_ALL_COOKIES)" {GET /session/:sessionId/cookie {sessionId} {}}
		"$Command(ADD_COOKIE)" {POST /session/:sessionId/cookie {sessionId} {dict cookie {$json_spec(COOKIE)} }}
		"$Command(DELETE_ALL_COOKIES)" {DELETE /session/:sessionId/cookie {sessionId} {}}
		"$Command(DELETE_COOKIE)" {DELETE /session/:sessionId/cookie/:name {sessionId name}}
		"$Command(SWITCH_TO_FRAME)" {POST /session/:sessionId/frame {sessionId} {dict id json}}
		"$Command(SWITCH_TO_PARENT_FRAME)" {POST /session/:sessionId/frame/parent {sessionId} {}}
		"$Command(SWITCH_TO_WINDOW)" {POST /session/:sessionId/window {sessionId} {dict name string}}
		"$Command(CLOSE)" {DELETE /session/:sessionId/window {sessionId} {}}
		"$Command(GET_VALUE_OF_CSS_PROPERTY)" {GET /session/:sessionId/element/:id/css/:propertyName {sessionId id propertyName}}
		"$Command(IMPLICIT_WAIT)" {POST /session/:sessionId/timeouts/implicit_wait {sessionId} {ms number}}
		"$Command(EXECUTE_ASYNC_SCRIPT)" {POST /session/:sessionId/execute_async {sessionId} {dict script string args {list json}}}
		"$Command(SET_SCRIPT_TIMEOUT)" {POST /session/:sessionId/timeouts/async_script {sessionId} {dict ms number}}
		"$Command(SET_TIMEOUTS)" {POST /session/:sessionId/timeouts {sessionId} {dict type string ms number}}
		"$Command(DISMISS_ALERT)" {POST /session/:sessionId/dismiss_alert {sessionId} {}}
		"$Command(ACCEPT_ALERT)" {POST /session/:sessionId/accept_alert {sessionId} {}}
		"$Command(SET_ALERT_VALUE)" {POST /session/:sessionId/alert_text {sessionId} {dict text string}}
		"$Command(GET_ALERT_TEXT)" {GET /session/:sessionId/alert_text {sessionId} {}}
		"$Command(CLICK)" {POST /session/:sessionId/click {sessionId} {dict button number}}
		"$Command(DOUBLE_CLICK)" {POST /session/:sessionId/doubleclick {sessionId} {}}
		"$Command(MOUSE_DOWN)" {POST /session/:sessionId/buttondown {sessionId} {dict button number}}
		"$Command(MOUSE_UP)" {POST /session/:sessionId/buttonup {sessionId} {dict button number}}
		"$Command(MOVE_TO)" {POST /session/:sessionId/moveto {sessionId} {dict element string xoffset number yoffset number}}
		"$Command(GET_WINDOW_SIZE)" {GET /session/:sessionId/window/:windowHandle/size {sessionId windowHandle}}
		"$Command(SET_WINDOW_SIZE)" {POST /session/:sessionId/window/:windowHandle/size {sessionId windowHandle} {dict width number height number}}
        "$Command(W3C_GET_WINDOW_SIZE)" {GET /session/:sessionId/window/size {sessionId}}
        "$Command(W3C_SET_WINDOW_SIZE)" {POST /session/:sessionId/window/size {dict width number height number}}
		"$Command(GET_WINDOW_POSITION)" {GET /session/:sessionId/window/:windowHandle/position {sessionId windowHandle}}
		"$Command(SET_WINDOW_POSITION)" {POST /session/:sessionId/window/:windowHandle/position {sessionId windowHandle} {dict x number y number}}
		"$Command(MAXIMIZE_WINDOW)" {POST /session/:sessionId/window/:windowHandle/maximize {sessionId windowHandle}}
        "$Command(W3C_MAXIMIZE_WINDOW)" {POST /session/:sessionId/window/maximize {sessionId}}
		"$Command(SET_SCREEN_ORIENTATION)" {POST /session/:sessionId/orientation {sessionId} {dict orientation string}}
		"$Command(GET_SCREEN_ORIENTATION)" {GET /session/:sessionId/orientation {sessionId} {}}
		"$Command(SINGLE_TAP)" {POST /session/:sessionId/touch/click {sessionId} {dict element string}}
		"$Command(TOUCH_DOWN)" {POST /session/:sessionId/touch/down {sessionId} {dict x number y number}}
		"$Command(TOUCH_UP)" {POST /session/:sessionId/touch/up {sessionId} {dict x number y number}}
		"$Command(TOUCH_MOVE)" {POST /session/:sessionId/touch/move {sessionId} {dict x number y number}}
		"$Command(TOUCH_SCROLL)" {POST /session/:sessionId/touch/scroll {sessionId} {dict element string xoffset number yoffset number}}
		"$Command(DOUBLE_TAP)" {POST /session/:sessionId/touch/doubleclick {sessionId} {dict element string}}
		"$Command(LONG_PRESS)" {POST /session/:sessionId/touch/longclick {sessionId} {dict element string}}
		"$Command(FLICK)" {POST /session/:sessionId/touch/flick {sessionId} {dict element string xoffset number yoffset number speed number}}
		"$Command(EXECUTE_SQL)" {POST /session/:sessionId/execute_sql {sessionId} {}}
		"$Command(GET_LOCATION)" {GET /session/:sessionId/location {sessionId} {}}
		"$Command(SET_LOCATION)" {POST /session/:sessionId/location {sessionId} {dict location {dict latitude number longitude number altitude number}}}
		"$Command(GET_APP_CACHE)" {GET /session/:sessionId/application_cache {sessionId} {}}
		"$Command(GET_APP_CACHE_STATUS)" {GET /session/:sessionId/application_cache/status {sessionId} {}}
		"$Command(CLEAR_APP_CACHE)" {DELETE /session/:sessionId/application_cache/clear {sessionId} {}}
		"$Command(GET_NETWORK_CONNECTION)" {GET /session/:sessionId/network_connection {sessionId} {}}
		"$Command(SET_NETWORK_CONNECTION)" {POST /session/:sessionId/network_connection {sessionId} {}}
		"$Command(GET_LOCAL_STORAGE_ITEM)" {GET /session/:sessionId/local_storage/key/:key {sessionId key}}
		"$Command(REMOVE_LOCAL_STORAGE_ITEM)" {DELETE /session/:sessionId/local_storage/key/:key {sessionId key}}
		"$Command(GET_LOCAL_STORAGE_KEYS)" {GET /session/:sessionId/local_storage {sessionId} {}}
		"$Command(SET_LOCAL_STORAGE_ITEM)" {POST /session/:sessionId/local_storage {sessionId} {dict key string value string}}
		"$Command(CLEAR_LOCAL_STORAGE)" {DELETE /session/:sessionId/local_storage {sessionId} {}}
		"$Command(GET_LOCAL_STORAGE_SIZE)" {GET /session/:sessionId/local_storage/size {sessionId} {}}
		"$Command(GET_SESSION_STORAGE_ITEM)" {GET /session/:sessionId/session_storage/key/:key {sessionId key}}
		"$Command(REMOVE_SESSION_STORAGE_ITEM)" {DELETE /session/:sessionId/session_storage/key/:key {sessionId key}}
		"$Command(GET_SESSION_STORAGE_KEYS)" {GET /session/:sessionId/session_storage {sessionId} {}} 
		"$Command(SET_SESSION_STORAGE_ITEM)" {POST /session/:sessionId/session_storage {sessionId} {dict key string value string}}
		"$Command(CLEAR_SESSION_STORAGE)" {DELETE /session/:sessionId/session_storage {sessionId} {}}
		"$Command(GET_SESSION_STORAGE_SIZE)" {GET /session/:sessionId/session_storage/size {sessionId} {}}
		"$Command(GET_LOG)" {POST /session/:sessionId/log {sessionId} {dict type string}}
		"$Command(GET_AVAILABLE_LOG_TYPES)" {GET /session/:sessionId/log/types {sessionId} {}}
	}]
	
}
