namespace eval ::selenium {
    
	# Defines constants for the standard WebDriver commands.
	#
	# While these constants have no meaning in and of themselves, they are
	# used to marshal commands through a service that implements WebDriver's
	# remote wire protocol:
	#
	# http://code.google.com/p/selenium/wiki/JsonWireProtocol
	#
	# Keep in sync with org.openqa.selenium.remote.DriverCommand

	variable Command 
	
	array set Command {
		STATUS  "status"
		NEW_SESSION  "new session"
		GET_ALL_SESSIONS  "get all sessions"
		DELETE_SESSION  "delete session"
		CLOSE  "close"
		QUIT  "quit"
		GET  "get"
		GO_BACK  "go back"
		GO_FORWARD  "go forward"
		REFRESH  "refresh"
		ADD_COOKIE  "add cookie"
		GET_COOKIE  "get cookie"
		GET_ALL_COOKIES  "get cookies"
		DELETE_COOKIE  "delete cookie"
		DELETE_ALL_COOKIES  "delete all cookies"
		FIND_ELEMENT  "find element"
		FIND_ELEMENTS  "find elements"
		FIND_CHILD_ELEMENT  "find child element"
		FIND_CHILD_ELEMENTS  "find child elements"
		CLEAR_ELEMENT  "clear element"
		CLICK_ELEMENT  "click element"
		SEND_KEYS_TO_ELEMENT  "send keys to element"
		TYPEWRITE  "typewrite"
		SUBMIT_ELEMENT  "submit element"
		UPLOAD_FILE  "upload file"
		GET_CURRENT_WINDOW_HANDLE  "get current window handle"
		GET_WINDOW_HANDLES  "get window handles"
		GET_WINDOW_SIZE  "get window size"
        W3C_GET_WINDOW_SIZE "W3C get window size"
        W3C_SET_WINDOW_SIZE "W3C set window size"
		GET_WINDOW_POSITION  "get window position"
		SET_WINDOW_SIZE  "set window size"
		SET_WINDOW_POSITION  "set window position"
		SWITCH_TO_WINDOW  "switch to window"
		SWITCH_TO_FRAME  "switch to frame"
		SWITCH_TO_PARENT_FRAME  "switch to parent frame"
		GET_ACTIVE_ELEMENT  "get active element"
		GET_CURRENT_URL  "get current url"
		GET_PAGE_SOURCE  "get page source"
		GET_TITLE  "get title"
		EXECUTE_SCRIPT  "execute script"
		GET_ELEMENT_TEXT  "get element text"
		GET_ELEMENT_VALUE  "get element value"
		GET_ELEMENT_TAG_NAME  "get element tag name"
		SET_ELEMENT_SELECTED  "set element selected"
		IS_ELEMENT_SELECTED  "is element selected"
		IS_ELEMENT_ENABLED  "is element enabled"
		IS_ELEMENT_DISPLAYED  "is element displayed"
		GET_ELEMENT_LOCATION  "get element location"
		GET_ELEMENT_LOCATION_ONCE_SCROLLED_INTO_VIEW  "get element location once scrolled into view"
		GET_ELEMENT_SIZE  "get element size"
		GET_ELEMENT_RECT  "get element rect"
		GET_ELEMENT_ATTRIBUTE  "get element attribute"
        GET_ELEMENT_PROPERTY "get element property"
		GET_VALUE_OF_CSS_PROPERTY  "get value of CSS property"
		ELEMENT_EQUALS  "element equals"
		SCREENSHOT  "screenshot"
		ELEMENT_SCREENSHOT "element screenshoot"
		IMPLICIT_WAIT  "implicitly wait"
		EXECUTE_ASYNC_SCRIPT  "execute async script"
		SET_SCRIPT_TIMEOUT  "set script timeout"
		SET_TIMEOUTS  "set timeouts"
		MAXIMIZE_WINDOW  "window maximize"
        W3C_MAXIMIZE_WINDOW  "W3C window maximize"
		GET_LOG  "get log"
		GET_AVAILABLE_LOG_TYPES  "get available log types"
	
		DISMISS_ALERT  "dismiss alert"
		ACCEPT_ALERT  "accept alert"
		SET_ALERT_VALUE  "set alert value"
		GET_ALERT_TEXT  "get alert text"

		CLICK  "mouse click"
		DOUBLE_CLICK  "mouse double click"
		MOUSE_DOWN  "mouse button down"
		MOUSE_UP  "mouse button up"
		MOVE_TO  "mouse move to"

		SET_SCREEN_ORIENTATION  "set screen orientation"
		GET_SCREEN_ORIENTATION  "get screen orientation"

		SINGLE_TAP  "touch single tap"
		TOUCH_DOWN  "touch down"
		TOUCH_UP  "touch up"
		TOUCH_MOVE  "touch move"
		TOUCH_SCROLL  "touch scroll"
		DOUBLE_TAP  "touch double tap"
		LONG_PRESS  "touch long press"
		FLICK  "touch flick"

		#HTML 5
		EXECUTE_SQL  "execute SQL"

		GET_LOCATION  "get location"
		SET_LOCATION  "set location"

		GET_APP_CACHE  "get app cache"
		GET_APP_CACHE_STATUS  "get app cache status"
		CLEAR_APP_CACHE  "clear app cache"

		GET_NETWORK_CONNECTION  "get network connection"
		SET_NETWORK_CONNECTION  "set network connection"

		GET_LOCAL_STORAGE_ITEM  "get local storage item"
		REMOVE_LOCAL_STORAGE_ITEM  "remove local storage item"
		GET_LOCAL_STORAGE_KEYS  "get local storage keys"
		SET_LOCAL_STORAGE_ITEM  "set local storage item"
		CLEAR_LOCAL_STORAGE  "clear local storage"
		GET_LOCAL_STORAGE_SIZE  "get local storage size"

		GET_SESSION_STORAGE_ITEM  "get session storage item"
		REMOVE_SESSION_STORAGE_ITEM  "remove session storage item"
		GET_SESSION_STORAGE_KEYS  "get session storage keys"
		SET_SESSION_STORAGE_ITEM  "set session storage item"
		CLEAR_SESSION_STORAGE  "clear session storage"
		GET_SESSION_STORAGE_SIZE  "get session storage size"
	}
	
	
}
