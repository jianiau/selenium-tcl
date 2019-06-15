lappend auto_path [file normalize [file join [pwd] ..]]

#package require selenium::firefox
#set driver [::selenium::FirefoxDriver new]

package require selenium::chrome
set driver [::selenium::ChromeDriver new]

$driver get http://www.google.com

set input_q [$driver find_element_by_name q]

$driver send_keys $input_q "hello world"

# Example of execute_javascript method
set element [$driver execute_javascript {return document.body} -returns_element]
puts "extracted the body element: $element"

after 4000

puts "Finishing the program..."
$driver quit
