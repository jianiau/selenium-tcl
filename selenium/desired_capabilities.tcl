namespace eval ::selenium {
    # The Desired Capabilities implementation.
    #
	# Set of default supported desired capabilities.
	#
	# Use this as a starting point for creating a desired capabilities object for 
	# requesting remote webdrivers for connecting to selenium server or selenium grid.
	#
	#
	# Usage Example:
	#
    #   package require selenium::utils::port
    #
    #   set port [selenium::utils::port::get_free_port]
    #
    #   exec java -jar seleniumjar.version.jar -Dwebdriver.chrome.driver=./chromedriver -port $port &
    #
	#	# Create a desired capabilities object as a starting point.
	#	set capabilities $::selenium::DesiredCapabilities(FIREFOX)
	#	dict set capabilities platform "WINDOWS"
	#	dict set capabilities version "10"
	#
	#	# Instantiate an instance of Remote WebDriver with the desired capabilities.
	#	set driver [::selenium::WebDriver new http:://localhost:$port $capabilities]
	#


	namespace export desired_capabilities
	
	variable DesiredCapabilities
	
	set DesiredCapabilities(PHANTOMJS) {
                                        browserName phantomjs
                                        version ""
                                        platform ANY 
                                        javascriptEnabled true}
											
	set DesiredCapabilities(ANDROID) {
                                        browserName android
                                        version ""
                                        platform ANDROID
                                        javascriptEnabled true}
											
	set DesiredCapabilities(HTMLUNIT) {
                                        browserName htmlunit
                                        version ""
                                        platform ANY}
											
	set DesiredCapabilities(IPAD) {
                                        browserName iPad
                                        version ""
                                        platform MAC
                                        javascriptEnabled true}
											
	set DesiredCapabilities(HTMLUNITWITHJS) {
                                        browserName htmlunit
                                        version firefox
                                        platform ANY
                                        javascriptEnabled true}
											
	set DesiredCapabilities(SAFARI) {
                                        browserName safari
                                        version ""
                                        platform ANY
                                        javascriptEnabled true}
											
	set DesiredCapabilities(CHROME) {
                                        browserName chrome
                                        version ""
                                        platform ANY
                                        javascriptEnabled true }

	set DesiredCapabilities(INTERNETEXPLORER) {
                                        browserName "internet explorer"
                                        version ""
                                        platform WINDOWS
                                        javascriptEnabled true}

	set DesiredCapabilities(IPHONE) {
                                        browserName iPhone
                                        version ""
                                        platform MAC
                                        javascriptEnabled true}

	set DesiredCapabilities(OPERA) {
                                        browserName opera
                                        version ""
                                        platform ANY
                                        javascriptEnabled true}

	set DesiredCapabilities(FIREFOX) { 
                                        browserName firefox
                                        version ""
                                        platform ANY
                                        javascriptEnabled true}
											
	proc desired_capabilities {browser_name} {
		variable DesiredCapabilities
		return $DesiredCapabilities($browser_name)
	}
	
}
