# Selenium
Selenium is a test tool for web applications. It can be used for writting spiders.

# 1. Getting Started
## 1.1. Simple Usage

Once the package selenium is installed and can be found using the variable **auto_path**,  you can start using it:

```tcl
package require selenium::chrome

namespace import ::selenium::ChromeDriver

set driver [ChromeDriver new]

$driver get http://wiki.tcl.tk/

puts [$driver title]
set input_search [$driver find_element_by_id searchtxt]
$driver send_keys $input_search selenium
$driver send_keys $input_search $selenium::Key(RETURN)
after 4000
$driver close
```

The above script can be saved into a file (eg:- wiki_tcl_search.tcl), then it can be run like this:

    tclsh wiki_tcl_search.tcl


## 1.2. Walk through of the example

The ::selenium namespace contains all the WebDriver implementations. 
Currently supported WebDriver implementations are:

    - FirefoxDriver
    - ChromeDriver
    - ChromiumDriver
    - PhantomJSdriver
    - IEdriver

The Key array provide symbolic names for keyboard keys like RETURN, F1, ALT etc.

The first step is to explicitly require chrome driver.

```tcl
package require selenium::chrome
```

When a driver is required, all the selenium package is loaded. This means that it's not necessary to require 
selenium.

We import the ChromeDriver class, and the instance of Chrome WebDriver is created.

```tcl
namespace import ::selenium::ChromeDriver

set driver [ChromeDriver new]
```

The driver *get* method will navigate to a page given by the URL. WebDriver will wait until the page has fully loaded (that is, the “onload” event has fired) before returning control to your  script. It’s worth noting that if your page uses a lot of AJAX on load then WebDriver may not know when it has completely loaded.:

```tcl
$driver get http://wiki.tcl.tk/
```

The next line prints the title.
```tcl
puts [$driver title]
```

WebDriver offers a number of ways to find elements using one of the *find_element_by_* methods. For example, the input text element can be located by its name attribute using find_element_by_name method. Detailed explanation of finding elements is available in the Locating Elements chapter:
```tcl
set q [$driver find_element_by_name q]
```

Next we are sending keys, this is similar to entering keys using your keyboard. Special keys can be send using Key array imported from the selenium namespace:
```tcl
$driver send_keys $q "hello world"
$driver send_keys $q $Key(RETURN)
```
(Remember to upvar Key array from selenium namespace or specify the complete name ::selenium::Key)

After submission of the page, you should get the result if there is any.
Finally, the browser window is closed. You can also call quit method instead of close. The quit will exit entire browser whereas close` will close one tab, but if just one tab was open, by default most browser will exit entirely.:
```tcl
$driver close
```

It's also possible to create a command for each web element retrieved instead of using the selenium ID provided.
In this case, the user indicates the variable containing the command name with the option *-command_var*
```tcl 
$driver find_element -css form.search -command_var form
$form find_element -name q -command_var query
$query send_keys {hello world!}
$query send_keys $Keys(RETURN)

$form find_element -css {input[type="submit"]} -command_var submit
$submit click
```

## 2. Drivers of selenium
### 2.1 Chrome
Chrome driver requires chromedriver. chromedriver can be explicitly passed to the constructor

```tcl
    ChromeDriver -binary path_to_chromedriver
```

Or it should be in the current working directory, or its directory should be added to the enviroment variable PATH.

Chrome driver can be downloaded here:
   http://sites.google.com/a/chromium.org/chromedriver/downloads
   
### 2.2 Chromium
Chromium driver has the same options than chrome. It use the same driver
```tcl
    ChromiumDriver -binary path_to_chromedriver
```

### 2.3 Firefox
#### 2.3.1 Firefox using geckodriver
Firefox version 47 and onwards require geckodriver
    
Geckodriver can be downloaded here:
   http://github.com/mozilla/geckodriver/releases

geckodriver can be explicitly passed to the constructor

```tcl
    FirefoxDriver -binary path_to_geckodriver
```

Or it should be in the current working directory, or its directory should be added to the enviroment variable PATH.

There is some difference between this driver and the other drivers:

   - The click method in the other drivers scroll into view the element and then make a click. The click method using geckodriver doesnt scroll into view the element. The user has to make this call first:
```
    $driver scroll_into_view $element
```

#### 2.2.3 Firefox using extension
Firefox version before 47 requires:

    - 7z or its standlone version 7za
    - the Tcl extension tdom. 

The path to this executable 7za or 7z can be passed to the constructor of FirefoxDriver with this option *-7z*.

```tcl
    FirefoxDriver -7z path_to_7z
```

Another possibility is to add the 7za executable in the current working directory or add the directory containing 
 7z or 7za to the enviroment variable PATH.

7z and its standlone version 7za can be downloaded here:
http://www.7-zip.org/download.html

Activestate Tcl has tdom included in its batteries. If you need to install this extension, you can download it
here:
https://tdom.github.io/

### 2.4 PhantomJS
This driver requires the headless browser PhantomJS. This headless browser can be downloaded here:
   http://phantomjs.org/download.html

The executable can be provided explicitly to the PhantomJSdriver constructor through the *-binary* option,
or should be in the current working directory or its directory should be added to the PATH.

```tcl
    PhantomJSdriver -binary path_to_phantomjs
```

### 2.5 Internet Explorer
This driver requires  *IEDriverServer.exe*.

This executable can be downloaded here:
   http://docs.seleniumhq.org/download/

And can be passed explicitly with the *-binary* option of the constructor or should be in the current working directory or its 
directory should be added to the PATH.

```tcl
    IEDriver -binary path_to_iedriverserver_exe
```

The IE driver require some extra steps depending of the internet explorer version:
https://github.com/SeleniumHQ/selenium/wiki/InternetExplorerDriver

### 2.6 HTMLUNIT
HTMLUNIT requires the selenium stanlone server can be downloaded here:
   http://www.seleniumhq.org/download/

``` tcl
    package require selenium
    package require selenium::utils::port

    set port [::selenium::utils::port::get_free_port]
    exec java -jar selenium-server-standlone-version.jar -port $port &

    set driver [::selenium::WebDriver new http://127.0.0.1:4444/wd/hub $::selenium::DesiredCapabilities(HTMLUNITWITHJS)]
    $driver get http://www.uab.es
```


## 3. Selenium Grid
Selenium grid requires de *seleniumjar* file.

The selenium stanlone server can be downloaded here:
   http://www.seleniumhq.org/download/

Documentation for selenium grid:
   https://github.com/SeleniumHQ/selenium/wiki/Grid2

Example:
```tcl
    package require selenium
    package require selenium::utils::port

    set port [::selenium::utils::port::get_free_port]
    exec java -jar seleniumjar.version.jar -Dwebdriver.chrome.driver=./chromedriver -port $port &

    # Create a desired capabilities object as a starting point. 
    set capabilities $::selenium::DesiredCapabilities(FIREFOX)
    dict set capabilities platform "WINDOWS"
    dict set capabilities version "10"

    # Instantiate an instance of Remote WebDriver with the desired capabilities.
    set driver [::selenium::WebDriver new http:://localhost:$port $capabilities]
```

## 4. Driver
The driver object has these subcommands:
  - **start_client**
  
    Called before starting a new session. This method may be overridden to define custom startup behavior.

  - **start_session**
  
    Creates a new session with the desired capabilities.
   
    Arguments:
    -  desiredCapabilities: It's a dictionary with these keys:
        - browser_name - The name of the browser to request.
        - version - Which browser version to request.
        - platform - Which platform to request the browser on.
        - javascript_enabled - Whether the new session should support JavaScript.
        - browser_profile - A selenium.driver.firefox.firefox_profile.FirefoxProfile object. Only used if Firefox is requested.

  - **get**

    Loads a web page in the current browser session.
    
    Arguments:
    - url

  - **title**

    Returns the title of the current page.
   
    Usage:
    ```tcl
   	driver title
    ```

  - **execute_javascript** script args
  
    Executes JavaScript in the current window/frame synchronously or asynchronously.
   
    Arguments:
    - script: The JavaScript to execute.
   
    :Options:
    
    - arguments spec1? arg1? spec2? arg2?...: Pairs of json specifications and tcl values as arguments for your JavaScript.
    - async: Execute javascript asyncronously
    - command_var: Variable to store the new command for the element/s
    - returns_element: Flag indicating that the script returns an element
    - returns_elements: Flag indicating that the script returns a list of elements
   
    Usage:
    ```tcl
    	driver execute_javascript {return document.title}
    ```

  - **execute_script** script args
    
    Forward method to *execute_javascript"
 
  - **remove_webelement_from_DOM**

    It removes a webelement from DOM
   
    Arguments:
    - element_ID: The element ID of the webelement to remove

  - **get_base64_image** 
    
    Arguments:
    - image_webelement

  - **is_select_element**

    Arguments:
    - element_ID

  - **tag_name**
  
    Gets this element's tagName property.
    
    Arguments:
    - element_ID

  - **get_visible_text**

    Gets the visible text of the element.

    Arguments:
    - element_ID

  - **get_text**
  
    Gets the text of the element.

    Arguments:
    - element_ID    

  - **clear_text**

    Clears the text if it's a text entry element.

    Arguments:
    - element_ID
    
  - **get_attribute**

    Gets the given attribute or property of the element.
   
    This method will return the value of the given property if this is set,
    otherwise it returns the value of the attribute with the same name if
    that exists, or None.
   
    Arguments:
    - element_ID
    - attribute_name - Name of the attribute/property to retrieve.
   
    Example:
   
    Check if the "active" CSS class is applied to an element
    
    ```
    	set class_attribute	[$driver get_element_attribute $target_element class]
		set is_active [expr {[string first $class_attribute active]!=-1}]
    ```

  - **is_selected**
  
    Whether the element is selected.
   
    Can be used to check if a checkbox or radio button is selected.
    
    Arguments:
    - element_ID

  - **is_enabled**

    Whether the element is enabled.
    
    Arguments:
    - element_ID

  - **location_once_scrolled_into_view**
  
    CONSIDERED LIABLE TO CHANGE WITHOUT WARNING. Use this to discover where on the screen an
    element is so that we can click it. This method should cause the element to be scrolled
    into view.
   
    Returns the top lefthand corner location on the screen, or None if the element is not visible

    Arguments:
    - element_ID

  - **size**

    Returns the size of the element
    
    Arguments:
    - element_ID

  - **get_location**

    Returns the location of the element in the renderable canvas
    
    Arguments:
    - element_ID

  - **get_rect**

    Returns a dictionary with the size and location of the element
    
    Arguments:
    - element_ID

  - **page_source**
  
    Gets the source of the current page.
   
    Usage:
    ```tcl
    	driver page_source
    ```

  - **close**

    Closes the current window.
   
    Usage:
    ```tcl
    	driver close
    ```

  - **quit**

    Quits the driver and closes every associated window.
   
    Usage:
    	driver quit

  - **current_window_handle**

    Returns the handle of the current window.
   
    Usage:
    ```tcl
    	driver current_window_handle
    ```

  - **window_handles**

    Returns the handles of all windows within the current session.
   
    Usage:
    ```tcl
    	driver window_handles
    ```

  - **maximize_window**

    Maximizes the current window that driver is using

  - **back**

    Goes one step backward in the browser history.
   
    Usage:
    ```tcl
    	driver back
    ```

  - **forward**

    Goes one step forward in the browser history.
   
    Usage:
    ```tcl
    	driver forward
    ```

  - **refresh**

    Refreshes the current page.

  - **get_cookies**

    Returns a set of dictionaries, corresponding to cookies visible in the current session.
   
    Usage:
    ```tcl
    	driver get_cookies
    ```

  - **get_cookie** name

    Get a single cookie by name. Returns the cookie if found, None if not.
   
    Usage:
    ```tcl
        driver get_cookie 'my_cookie'
    ```
    
  - **delete_cookie**

    Deletes a single cookie with the given name.
    
    Arguments:
    - cookie_name

  - **add_cookie**

    Adds a cookie to your current session.
   
    Arguments:
    - cookie_dict: A dict object, with required keys: "name" and "value";
    
    <pre>
    optional keys - "path", "domain", "secure", "expiry"
   
    Key 		Type 		Description
    name 		string 		The name of the cookie.
    value 	    string 		The cookie value.
    path 		string 		(Optional) The cookie path.1
    domain 	    string 		(Optional) The domain the cookie is visible to.1
    secure 	    boolean 	(Optional) Whether the cookie is a secure cookie.1
    httpOnly 	boolean 	(Optional) Whether the cookie is an httpOnly cookie.1
    expiry 	    number 		(Optional) When the cookie expires, specified in seconds since midnight, January 1, 1970 UTC.1
    </pre>
    
    Usage:
    ```tcl
    	driver add_cookie  name foo  value bar
    	driver add_cookie  name foo  value bar  path /
    	driver add_cookie  name foo  value bar  path /  secure true
    ```
  
  - **delete_all_cookies**

    Delete all cookies in the scope of the session.
    
  - **freeze**

    Freeze element or container of webelements
    The command will not be deleted when the program execution leaves the frame
    
    Arguments:
    - varname

  - **implicitly_wait**

    Sets a sticky timeout to implicitly wait for an element to be found,
    or a command to complete. This method only needs to be called one
    time per session. To set the timeout for calls to
    execute_async_script, see set_script_timeout.
   
    Arguments:
    - time_to_wait: Amount of time to wait (in seconds)
   
    Usage:
    ```tcl
    	driver implicitly_wait 30
    ```
  - **set_script_timeout**
 
    Set the amount of time that the script should wait during an
    execute_async_script call before throwing an error.
   
    Arguments:
    - time_to_wait: The amount of time to wait (in seconds)

  - **set_page_load_timeout**

    Set the amount of time to wait for a page load to complete
    before throwing an error.
   
    Arguments:
    - time_to_wait: The amount of time to wait
   
    Usage:
    ```tcl
    driver set_page_load_timeout 30
    ```

  - **current_capabilities**

    returns the drivers current desired capabilities being used

  - **get_screenshot_as_file**

    Gets the screenshot of the current window. Returns False if there is
    any IOError, else returns True. Use full paths in your filename.
   
    Arguments:
    - filename: The full path you wish to save your screenshot to.
   
    Usage:
    ```tcl
    	driver get_screenshot_as_file /Screenshots/foo.png
    ```
    
  - **get_screenshot_as_png**

    Gets the screenshot of the current window as a binary data.

  - **get_screenshot_as_base64**

    Gets the screenshot of the current window as a base64 encoded string
    which is useful in embedded images in HTML.
   
    Usage:
    	driver get_screenshot_as_base64

  - **set_window_size**

    Sets the width and height of the current window.
   
    Arguments:
    - width: the width in pixels to set the window to
    - height: the height in pixels to set the window to
    - windowHandle (Optional): Default value current
   
    Usage:
    ```tcl
    	driver set_window_size 800 600
    ```

  - **get_window_size**

    Gets the width and height of the current window.
   
    Arguments:
    - windowHandle (Optional): Default value 'current'.

    Usage:
    ```tcl
        driver get_window_size
    ```

  - **set_window_position**

    Sets the x,y position of the current window. (window.moveTo)
   
    Arguments:
    - x: the x-coordinate in pixels to set the window position
    - y: the y-coordinate in pixels to set the window position
    - windowHandle (Optional). Default value is 'current'

    Usage:
    ```tcl
    	driver set_window_position 0 0
    ```

  - **get_window_position**
    
    Arguments:
    - windowHandle (Optional). Default value is 'current'

    Gets the x,y position of the current window.

  - **get_screen_orientation**

    Gets the current orientation of the device

  - **set_screen_orientation**

    Sets the current orientation of the device
   
    Arguments:
    - value: orientation to set it to.
   
    Usage:
    ```tcl
    	driver set_orientation "landscape"
    ```

  - **available_log_types**
    Gets a list of the available log types
   
    Usage:
    ```tcl
    	driver log_types
    ```

  - **get_log**

    Gets the log for a given log type
   
    Arguments:
   
    - log_type: type of log that which will be returned
   
    Usage:
     ```tcl
    	driver get_log browser
    	driver get_log driver
    	driver get_log client
    	driver get_log server
     ```

  - **alert_text**

    Gets the text of the Alert.

  - **dismiss_alert**

    Dismisses the alert available.

  - **accept_alert**

    Accepts the alert available.
   
    Usage::
    	driver accept_alert # Confirm a alert dialog.

  - **send_keys_to_alert**

    Send Keys to the Alert.
   
    Arguments:
    - keysToSend: The text to be sent to Alert.

  - **get_app_cache_status**

    Returns a current status of application cache.

  - **scroll_into_view**

    Scroll element into view
    
    Arguments:
    - element_ID

  - **scroll_to_bottom**

    scroll to bottom of webpage

  - **scrolling_position**

    Get the scrolling position

  - **scroll_to_bottom_infinitely** 
  
    Scroll to bottom until condition provided is true or it's not possible to scroll more
    
    Arguments:
    - condition_command
    - timeout

  - **switch_to_default_frame**

    Switch focus to the default frame.
   
    Usage:
    ```tcl
    	driver switch_to_default_frame
    ```

  - **switch_to_frame**

    Switches focus to the specified frame, by index, name, or webelement.
   
    Arguments:
    - by
    - frame_reference: The name of the window to switch to, an integer representing the index,
    or a webelement that is an (i)frame to switch to.
   
    Usage:
    ```tcl
    	driver switch_to_frame -name $frame_name
    	driver switch_to_frame -index 1
    	driver switch_to_frame -element [[driver find_elements_by_tag_name iframe] index 0]
    ```

  - **switch_to_parent_frame**

    Switches focus to the parent context. If the current context is the top
    level browsing context, the context remains unchanged.
   
    Usage:
    ```tcl
    	driver switch_to_parent_frame
    ```

  - **switch_to_window**

    Switches focus to the specified window.
   
    Arguments:
    - window_name: The name or window handle of the window to switch to.
   
    Usage:
    ```tcl
    	driver switch_to_window main
    ```

  - **move_mouse_to**

    Move the mouse by an offset of the specificed element.
    If no element is specified, the move is relative to the current mouse cursor
    If an element is provided but no offset, the mouse will be moved to the center of the element.
    If the element is not visible, it will be scrolled into view.
   
    Arguments:
      - element: ID assigned to the webelement to move to, as described in the WebElement JSON Object.
      If not specified or is null, the offset is relative to current position of the mouse.
   
      - xoffset: X offset to move to, relative to the top-left corner of the element.
      If not specified, the mouse will move to the middle of the element.
   
      - yoffset: Y offset to move to, relative to the top-left corner of the element.
      If not specified, the mouse will move to the middle of the element.
   
    Usage:
    ```tcl
    	driver move_mouse_to 10 21 $element
    ```

  - **network_connection**

    ConnectionType is a bitmask to represent a device's network connection
    <PRE>
    Data | WIFI | Airplane
    0 	   0 	 1 			== 1
    1 	   1 	 0 			== 6
    1 	   0 	 0 			== 4
    0 	   1 	 0			== 2
    0 	   0 	 0 			== 0
    </PRE>
   
    Giving "Data" the first bit positions in order to give room for the future of enabling specific types of data (Edge / 2G, 3G, 4G, LTE, etc) if the device allows it.
   
 
  - **set_network_connection**

    Set the Connection type
    Not all connection type combinations are valid for an individual type of device
    and the remote endpoint will make a best effort to set the type as requested

  - **double_click**
  
    Make double click

  - **move_mouse**
  
    Moving the mouse to an offset from current mouse position.
    
    Arguments:
    - xoffset
    - yoffset

  - **move_mouse_to_element**

    Moving the mouse to the middle of an element, possibly adding some offsets
    
    - element_ID
    - xoffset (Optional)
    - yoffset (Optional)

  - **mouse_down**
  
    Press mouse button.
    
    Arguments:
    - buttonName

  - **mouse_up**
  
    Release mouse button
    
    Arguments:
    - buttonName

  - **find_element**
   
    Find element by strategy location
   
    Arguments:
    - strategy location:

   		-id
   		-xpath
   		-name
   		-link_text
   		-tag_name
   		-partial_link_text
   		-css
   		-class
   		-link_text
    - It's possible to find a descendant element from another element, indicating its element ID
    ```tcl
           -root *element_ID*
    ```
    - Build a new command if you want to apply several acctions to this element to avoid adding
    always its element ID. A new webelement object will be created.
    ```tcl
          - command_var *name_of_command_variable*
    ```
    
    Usage:
    ```tcl
   	driver find_element -css ".foo"
    ```

  - **find_elements**
   
    Finds elements by strategy location
   
    It has the same options than find_element.
    The option "-command_var" builds a container of webelements object.
   
    Usage:
    ```tcl
   	driver find_elements -css ".foo"
    ```

  - **find_element_by_id**
  
    Finds an element by id.
   
    Arguments:
    - id - The id of the element to be found.
   
    Usage:
    ```tcl
       $driver find_element_by_id foo
    ```

  - **find_elements_by_id**
  
    Finds multiple elements by id.
   
    Arguments:
    - id - The id of the elements to be found.
   
    Usage:
    ```
       $driver find_element_by_id foo
    ```
   
  - **find_element_by_xpath**
  
    Finds an element by xpath.
   
    Arguments:
    - xpath - The xpath locator of the element to find.
   
    Usage:
    ```tcl
       $driver find_element_by_xpath {//div/td[1 -level 1 {*}$args]}
    ```

  - **find_elements_by_xpath**
  
    Finds multiple elements by xpath.
   
    Arguments:
    - xpath - The xpath locator of the elements to be found.
   
    Usage:
    ```tcl
       $driver find_elements_by_xpath {//div[contains(@class, foo -level 1 {*}$args]}
    ```

  - **find_element_by_link_text**
  
    Finds an element by link text.
   
    Arguments:
    - link_text: The text of the element to be found.
   
    Usage:
    ```tcl
       $driver find_element_by_link_text {Sign In}
    ```

  - **find_elements_by_link_text**
  
    Finds elements by link text.
   
    Arguments:
    - link_text: The text of the elements to be found.
   
    Usage:
    ```tcl
       $driver find_elements_by_link_text 'Sign In'
    ```

  - **find_element_by_partial_link_text** link_text
  
    Finds an element by a partial match of its link text.
   
    Arguments:
    - link_text: The text of the element to partially match on.
   
    Usage:
    ```tcl
       $driver find_element_by_partial_link_text Sign
    ```

  - **find_elements_by_partial_link_text** link_text
  
    Finds elements by a partial match of their link text.
   
    Arguments:
    - link_text: The text of the element to partial match on.
   
    Usage:
    ```tcl
       $driver find_element_by_partial_link_text Sign
    ```

  - **find_element_by_name**
  
    Finds an element by name.
   
    Arguments:
    - name: The name of the element to find.
   
    Usage:
    ```tcl
       $driver find_element_by_name foo
    ```

  - **find_elements_by_name**
  
    Finds elements by name.
   
    Arguments:
    - name: The name of the elements to find.
   
    Usage:
    ```tcl
       $driver find_elements_by_name foo
    ```

  - **find_element_by_tag_name**
  
    Finds an element by tag name.
   
    Arguments:
    - tag_name: The tag name of the element to find.
   
    Usage:
    ```tcl
       $driver find_element_by_tag_name foo
    ```
     
  - **find_elements_by_tag_name**
  
    Finds elements by tag name.
   
    Arguments:
    - tag_name: The tag name the use when finding elements.
   
    Usage:
    ```tcl
       $driver find_elements_by_tag_name foo
    ```
  - **find_element_by_class_name**
  
    Finds an element by class name.
   
    Arguments:
    - class_name: The class name of the element to find.
   
    Usage:
    ```tcl
       $driver find_element_by_class_name foo
    ```

  - **find_elements_by_class_name**
  
    Finds elements by class name.
   
    Arguments:
    - class_name: The class name of the elements to find.
   
    Usage:
    ```tcl
       $driver find_elements_by_class_name foo
    ```
 
  - **find_element_by_css_selector**
  
    Finds an element by css selector.
   
    Arguments:
    - css_selector: The css selector to use when finding elements.
   
    Usage:
    ```tcl
       $driver find_element_by_css_selector #foo
    ```

  - **find_elements_by_css_selector**
  
    Finds elements by css selector.
   
    Arguments:
    - css_selector: The css selector to use when finding elements.
   
    Usage:
    ```tcl
       $driver find_elements_by_css_selector .foo
    ```

## 5. Expected conditions
It's possible to wait until some condition on the webpage happens.

For example, to wait 3 seconds until "seleninum is great" appears on the title of the window.
```tcl
    ::selenium::wait_until -driver $driver -condition [::selenium::expected_condition title_is "seleninum is great"] -timeout 4
```

If after this 3 seconds, the condition didn't happen a "Exception(Timeout)" is raised.

It's also possible to use this abbrevation `::selenium::EC`. For example, to wait 4 seconds until confirm_button
is nos present in the DOM:
```tcl
    ::selenium::wait_until -driver $driver -condition [::selenium::EC staleness_of $confirm_button] -timeout 4
```

This is a complete list of expected conditions:

   - **title_is** title

        An expectation for checking the title of a page.

        Arguments:
        - title: It's the expected title, which must be an exact match

   - **title_contains** text 

        An expectation for checking that the title contains a case-sensitive substring. 

        Arguments:
        - text: It's the fragment of title expected
        
   - **presence_of_element_located** by value element

        An expectation for checking that an element is present on the DOM
        of a page. This does not necessarily mean that the element is visible.
    
   - **visibility_of_element_located** by value

        An expectation for checking that an element is present on the DOM of a
        page and visible. Visibility means that the element is not only displayed
        but also has a height and width that is greater than 0.

    - **visibility_of** element

        An expectation for checking that an element, known to be present on the
        DOM of a page, is visible. Visibility means that the element is not only
        displayed but also has a height and width that is greater than 0.
        
        Arguments:
        - element: the element to wait of its visibility

    - **text_to_be_present_in_element** by value text

        An expectation for checking if the given text is present in the specified element by locator.

    - **text_to_be_present_in_element_value** by value text

        An expectation for checking if the given text is present in the element's locator, text

    - **element_has_this_attribute_value** element attribute_name attribute_value

        An expectation for checking if the given element has an specific attribute name and value
    
    
   - **frame_to_be_available_and_switch_to_it** optionName optionValue

        An expectation for checking whether the given frame is available to
        switch to.  If the frame is available it switches the given driver to the
        specified frame.

   - **invisibility_of_element_located** by value

        An Expectation for checking that an element is either invisible or not present on the DOM.
        In the case of NoSuchElement, returns true because the element is
        not present in DOM. The try block checks if the element is present but is invisible.
        
        In the case of StaleElementReference, returns true because stale element reference 
        implies that element is no longer visible.

   - **invisibility_of_all_elements_located** by value

        An Expectation for checking that all elements indicated are invisible

   - **element_to_be_clickable** by value

        An Expectation for checking an element is visible and enabled such that you can click it.

   - **staleness_of** element

        Wait until an element is no longer attached to the DOM.
        
        Arguments:
        - element: The element to wait for.

   - **element_to_be_selected** element

        An expectation for checking the selection is selected.
        element is WebElement object
        
    - **element_located_to_be_selected** by value

        An expectation for the element to be located is selected.

    - **element_selection_state_to_be** element is_selected

        An expectation for checking if the given element is selected.
        
        Arguments:
        - element
        - is_selected: Boolean indicating whether to wait for select or not select
    
    - **element_located_selection_state_to_be** by value is_selected

        An expectation to locate an element and check if the selection state
        specified is in that state.

        Arguments:
        - by: The strategy of location
        - value: The parameter value for that strategy
        - is_selected: Boolean indicating whether to wait for select or not select

    - **alert_is_present**

        Expect an alert to be present.

## 6. Xvfb
Tcl wrapper to xvfb server.

Example of usage:
```tcl
   package require selenium::firefox
   package require xvfbwrapper
   
   set xvfb [::xvfb::Xvfb new -width 342 -height 234]
   $xvfb start
     set driver [::selenium::FirefoxDriver -binary \path\to\geckodriver]
     $driver get http://www.google.es
   $xvfb stop
```

## 7. Constants

### Mouse Buttons
We have these symbolic names for the mouse buttons in the selenium namespace:
```
    Mouse_Button(LEFT)
    Mouse_Button(MIDDLE)
    Mouse_Button(RIGHT)
```

### Keys
We have these symbolic keys in the selenenium namespace:

```
    Key(CANCEL)
    Key(HELP)
    Key(BACKSPACE)
    Key(TAB)
    Key(CLEAR)
    Key(RETURN)
    Key(ENTER)
    Key(SHIFT)
    Key(CONTROL)
    Key(ALT)
    Key(PAUSE)
    Key(ESCAPE)
    Key(SPACE)
    Key(PAGEUP)
    Key(PAGEDOWN)
    Key(END)
    Key(HOME)
    Key(LEFTARROW)
    Key(UPARROW)
    Key(RIGHTARROW)
    Key(DOWNARROW)
    Key(INSERT)
    Key(DELETE)
    Key(EQUALS)
    Key(NUMPAD0)
    Key(NUMPAD1)
    Key(NUMPAD2)
    Key(NUMPAD3)
    Key(NUMPAD4)
    Key(NUMPAD5)
    Key(NUMPAD6)
    Key(NUMPAD7)
    Key(NUMPAD8)
    Key(NUMPAD9)
    Key(MULTIPLY)
    Key(ADD)
    Key(SEPARATOR)
    Key(SUBTRACT)
    Key(DECIMAL)
    Key(DIVIDE)
    Key(F1)
    Key(F2)
    Key(F3)
    Key(F4)
    Key(F5)
    Key(F6)
    Key(F7)
    Key(F8)
    Key(F9)
    Key(F10)
    Key(F11)
    Key(F12)
    Key(META)
```

### StatusCache

These are the symbolic values for the status cache:
```
	StatusCache(UNCACHED)
    StatusCache(IDLE)
    StatusCache(CHECKING)
    StatusCache(DOWNLOADING)
    StatusCache(UPDATE_READY)
    StatusCache(OBSOLETE)
```

### Exceptions
List of exceptions:

```
    Exception(ConnectionRefused)
        Connection refused. It's not possible to reach webdriver server.
        
    Exception(ElementIsNotSelectable)
        An attempt was made to select an element that cannot be selected.
        
    Exception(ElementNotSelectable)
        Thrown when trying to select an unselectable element.
        
        For example, selecting a 'script' element.
        
    Exception(ElementNotVisible)
        Thrown when an element is present on the DOM, but
        it is not visible, and so is not able to be interacted with.
        
        Most commonly encountered when trying to click or read text
        of an element that is hidden from view.
        
    Exception(ErrorInResponse)
        Thrown when an error has occurred on the server side.
        
        This may happen when communicating with the firefox extension or the remote driver server.
        
    Exception(IMEEngineActivationFailed)
        Thrown when activating an IME engine has failed.

    Exception(IMENotAvailable)
        Thrown when IME support is not available. This exception is thrown for every IME-related
        method call if IME support is not available on the machine.
        
    Exception(InvalidCommandMethod)
        If a request path maps to a valid resource, but that resource does not respond to the request method,
        the server should respond with a 405 Method Not Allowed. The response must include an Allows header with a 
        list of the allowed methods for the requested resource. 
        
    Exception(InvalidCookieDomain)
        Thrown when attempting to add a cookie under a different domain
        than the current URL.
        
    Exception(InvalidElementCoordinates)
         The coordinates provided to an interactions operation are invalid.
        
    Exception(InvalidElementState)
        Thrown when an unexpected alert is appeared.
        
        Usually raised when when an expected modal is blocking webdriver form executing any
        more commands.
        
    Exception(InvalidSelector)
        Thrown when the selector which is used to find an element does not return
        a WebElement. Currently this only happens when the selector is an xpath
        expression and it is either syntactically invalid (i.e. it is not a
        xpath expression) or the expression does not select WebElements
        (e.g. "count(//input)").
        
    Exception(InvalidSwitchToTarget)
        Thrown when frame or window target to be switched doesn't exist.
        
    Exception(JavaScriptError)
        An error occurred while executing user supplied JavaScript. 
        
    Exception(MissingCommandParameters)
        If a POST/PUT command maps to a resource that expects a set of JSON parameters, and the response body does
        not include one of those parameters, the server should respond with a 400 Bad Request.
        The response body should list the missing parameters. 	
        
    Exception(MoveTargetOutOfBounds)
        Thrown when the target provided to the `ActionsChains` move
        method is invalid, i.e. out of document.
        
    Exception(NoAlertOpen)
        An attempt was made to operate on a modal dialog when one was not open. 
        
    Exception(NoSuchAttribute)
        Thrown when the attribute of element could not be found.
        
        You may want to check if the attribute exists in the particular browser you are
        testing against.  Some browsers may have different property names for the same
        property.  (IE8's .innerText vs. Firefox .textContent)
        
    Exception(NoSuchDriver) 
        A session is either terminated or not started 
        
    Exception(NoSuchElement)
        Thrown when element could not be found.
        
        If you encounter this exception, you may want to check the following:
        * Check your selector used in your find_by...
        * Element may not yet be on the screen at the time of the find operation,
        (webpage is still loading)
        
    Exception(NoSuchFrame)
        Thrown when frame target to be switched doesn't exist.
        
    Exception(NoSuchWindow)
        Thrown when window target to be switched doesn't exist.
        
        To find the current set of active window handles, you can get a list
        of the active window handles in the following way::
        
        puts [$driver window_handles]
        
    Exception(ScriptTimeout)
        A script did not complete before its timeout expired. 
        
    Exception(SessionNotCreated)
        A new session could not be created. 
        
    Exception(StaleElementReference)
        Thrown when a reference to an element is now "stale".
        
        Stale means the element no longer appears on the DOM of the page.
        
        
        Possible causes of StaleElementReferenceException include, but not limited to:
        * You are no longer on the same page, or the page may have refreshed since the element was located.
        * The element may have been removed and re-added to the screen, since it was located.
        Such as an element being relocated.
        This can happen typically with a javascript framework when values are updated and the node is rebuilt.
        * Element may have been inside an iframe or another context which was refreshed.
        
    Exception(Timeout)
        Thrown when a command does not complete in enough time.
        
    Exception(UnableToSetCookie)
        Thrown when a driver fails to set a cookie.
        
    Exception(UnexpectedAlertOpen)
        Thrown when an unexpected alert is appeared.

        Usually raised when when an expected modal is blocking webdriver form executing any 
        more commands.
        
    Exception(UnexpectedTagName)
        Thrown when a support class did not get an expected web element.
        
    Exception(UnknownCommand)
        The requested resource could not be found, or a request was received using an HTTP method that is not
        supported by the mapped resource.
        
    Exception(UnknownError)
         An unknown server-side error occurred while processing the command. 
        
    Exception(WebdriverException)
        Unknown webdriver exception

    Exception(XPathLookupError)
         An error occurred while searching for an element by XPath. 
```
