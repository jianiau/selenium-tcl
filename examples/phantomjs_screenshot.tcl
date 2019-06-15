lappend auto_path [file normalize [file join [pwd] ..]]

package require selenium::phantomjs

namespace import ::selenium::*

set driver [PhantomJSdriver new]

$driver set_window_size 1500 1366

$driver get https://duckduckgo.com/

set input_homepage [$driver find_element -id search_form_input_homepage]
$driver send_keys $input_homepage "tcl programming language"

set search_button [$driver find_element -id search_button_homepage]
$driver click $search_button

puts "URL: [$driver current_url]"
$driver get_screenshot_as_file screenshot.png

puts "File saved"

$driver quit
