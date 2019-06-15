# Exceptions that may happen in all the webdriver code.

namespace eval ::selenium {		
	namespace export Exception
	
	variable Exception 

	array set Exception {
        WebdriverException { SELENIUM WebdriverException unknown {
            Webdriver Exception
            }
        }
        
		ConnectionRefused { SELENIUM ConnectionRefused {
            Connection refused. It's not possible to reach webdriver server.
            }
        }

		NoSuchDriver { SELENIUM NoSuchDriver { 
			A session is either terminated or not started 
			}
		}
		
		ErrorInResponse { SELENIUM ErrorInResponse {
			Thrown when an error has occurred on the server side.
			
			This may happen when communicating with the firefox extension or the remote driver server.
			}
		}
		

		InvalidSwitchToTarget { SELENIUM InvalidSwitchToTarget {
			Thrown when frame or window target to be switched doesn't exist.
			}
		}
		
		NoSuchElement { SELENIUM NoSuchElement {
			Thrown when element could not be found.
			
			If you encounter this exception, you may want to check the following:
			* Check your selector used in your find_by...
			* Element may not yet be on the screen at the time of the find operation,
			(webpage is still loading) see selenium.webdriver.support.wait.WebDriverWait()
			for how to write a wait wrapper to wait for an element to appear.
			}
		}

		NoSuchFrame { SELENIUM NoSuchFrame {
			Thrown when frame target to be switched doesn't exist.
			}
		}
		
		UnknownCommand { SELENIUM UnknownCommand {
			The requested resource could not be found, or a request was received using an HTTP method that is not
			supported by the mapped resource.
			}
		}
		

		NoSuchAttribute { SELENIUM NoSuchAttribute {
			Thrown when the attribute of element could not be found.
			
			You may want to check if the attribute exists in the particular browser you are
			testing against.  Some browsers may have different property names for the same
			property.  (IE8's .innerText vs. Firefox .textContent)
			}
		}

		StaleElementReference { SELENIUM StaleElementReference {
			Thrown when a reference to an element is now "stale".
			
			Stale means the element no longer appears on the DOM of the page.
			
			
			Possible causes of StaleElementReferenceException include, but not limited to:
			* You are no longer on the same page, or the page may have refreshed since the element was located.
			* The element may have been removed and re-added to the screen, since it was located.
			Such as an element being relocated.
			This can happen typically with a javascript framework when values are updated and the node is rebuilt.
			* Element may have been inside an iframe or another context which was refreshed.
			}
		}

		ElementNotVisible { SELENIUM ElementNotVisible {
			Thrown when an element is present on the DOM, but
			it is not visible, and so is not able to be interacted with.
			
			Most commonly encountered when trying to click or read text
			of an element that is hidden from view.
			}
		}


		InvalidElementState { SELENIUM InvalidElementState {
			Thrown when an unexpected alert is appeared.
			
			Usually raised when when an expected modal is blocking webdriver form executing any
			more commands.
			}
		}

		UnknownError { SELENIUM UnknownError {
			 An unknown server-side error occurred while processing the command. 
			}
		}
		
		ElementIsNotSelectable { SELENIUM ElementIsNotSelectable {
			An attempt was made to select an element that cannot be selected.
			}
		}
		
		JavaScriptError { SELENIUM JavaScriptError {
			An error occurred while executing user supplied JavaScript. 
			}
		}
		
		XPathLookupError { SELENIUM XPathLookupError {
			 An error occurred while searching for an element by XPath. 
			}
		}
		
		Timeout { SELENIUM Timeout {
			Thrown when a command does not complete in enough time.
			}
		}
		
		NoSuchWindow { SELENIUM NoSuchWindow {
			Thrown when window target to be switched doesn't exist.
			
			To find the current set of active window handles, you can get a list
			of the active window handles in the following way::
			
			print driver.window_handles
			}
		}


		InvalidCookieDomain { SELENIUM InvalidCookieDomain {
			Thrown when attempting to add a cookie under a different domain
			than the current URL.
			}
		}

		UnableToSetCookie { SELENIUM UnableToSetCookie {
			Thrown when a driver fails to set a cookie.
			}
		}

		UnexpectedAlertOpen { SELENIUM UnexpectedAlertOpen {
			Thrown when an unexpected alert is appeared.
    
			Usually raised when when an expected modal is blocking webdriver form executing any 
			more commands.
			}
		}
		
		NoAlertOpen { SELENIUM NoAlertOpen {
			An attempt was made to operate on a modal dialog when one was not open. 
			}
		}
		
		ScriptTimeout { SELENIUM ScriptTimeout {
			A script did not complete before its timeout expired. 
			}
		}
		
		InvalidElementCoordinates { SELENIUM InvalidElementCoordinates {
			 The coordinates provided to an interactions operation are invalid.
			}
		 }		 
		

		ElementNotSelectable { SELENIUM ElementNotSelectable {
			Thrown when trying to select an unselectable element.
			
			For example, selecting a 'script' element.
			}
		}


		UnexpectedTagName { SELENIUM UnexpectedTagName {
			Thrown when a support class did not get an expected web element.
			}
		}


		IMENotAvailable { SELENIUM IMENotAvailable {
			Thrown when IME support is not available. This exception is thrown for every IME-related
			method call if IME support is not available on the machine.
			}
		}
		
		IMEEngineActivationFailed { SELENIUM IMEEngineActivationFailed {
			Thrown when activating an IME engine has failed.} 
		}
		
		InvalidSelector { SELENIUM InvalidSelector {
			Thrown when the selector which is used to find an element does not return
			a WebElement. Currently this only happens when the selector is an xpath
			expression and it is either syntactically invalid (i.e. it is not a
			xpath expression) or the expression does not select WebElements
			(e.g. "count(//input)").
			}
		}

		SessionNotCreated { SELENIUM SessionNotCreated {
			A new session could not be created. 
			}
		}
		
		
		MoveTargetOutOfBounds { SELENIUM MoveTargetOutOfBounds {
			Thrown when the target provided to the `ActionsChains` move
			method is invalid, i.e. out of document.
			}
		}
		
		InvalidCommandMethod { SELENIUM InvalidCommandMethod {
			If a request path maps to a valid resource, but that resource does not respond to the request method,
			the server should respond with a 405 Method Not Allowed. The response must include an Allows header with a 
			list of the allowed methods for the requested resource. 
			}
		}
		
		MissingCommandParameters { SELENIUM MissingCommandParameters {
			If a POST/PUT command maps to a resource that expects a set of JSON parameters, and the response body does
			not include one of those parameters, the server should respond with a 400 Bad Request.
			The response body should list the missing parameters. 	
			}
		}
	}
	
	proc Exception {exceptionName} {
		variable Exception
		return $Exception($exceptionName)
	}
}
