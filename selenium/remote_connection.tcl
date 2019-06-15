package require http 2

package require selenium::utils::url_codification
package require selenium::utils::json

namespace eval ::selenium {

	namespace export Remote_Connection

    variable RESPONSE_SUCCESS 0
    variable RESPONSE_ERROR 1


	oo::class create Remote_Connection {
		#  A connection with the Remote WebDriver server.
		#
		# Communicates with the server using the WebDriver wire protocol:
		# http://code.google.com/p/selenium/wiki/JsonWireProtocol
		variable server_addr user_agent HTTP_TEMPLATES_OF_WEBDRIVER_PROTOCOL

		constructor {server_addr {user_agent "Selenium Tcl"}} {
			# se tiene que canonizar la url del servidor
			namespace eval [self] {
				namespace upvar ::selenium HTTP_TEMPLATES_OF_WEBDRIVER_PROTOCOL HTTP_TEMPLATES_OF_WEBDRIVER_PROTOCOL
			}

            namespace import ::selenium::utils::url_codification::url_encode ::selenium::utils::json::compile_to_json ::selenium::utils::json::json_to_tcl

			if {[string match */ $server_addr]} {
				set server_addr [string range $server_addr 0 end-1]
			}

			set [self]::server_addr $server_addr
			set [self]::user_agent $user_agent
		}


		method dispatch {session_ID command_name command_parameters} {
			# Send a command to the remote server.
			#
			# Any path subtitutions required for the URL mapped to the command should be
			# included in the command parameters.
			#
			# :Args:
			# - command - A string specifying the command to execute.
			# - params - A dictionary of named parameters to send with the command as
			#	its JSON payload.

			set request_template [dict get $HTTP_TEMPLATES_OF_WEBDRIVER_PROTOCOL $command_name]

            lassign $request_template http_method url_subpath url_parameters json_specification_of_parameters

			if {[llength $url_parameters] != 0} {

				foreach parameter_name $url_parameters {
					if {$parameter_name == "sessionId"} {
						lappend template_mapping :sessionId $session_ID
					} else {
						set parameter_value [url_encode [dict get $command_parameters $parameter_name]]
						lappend template_mapping ":$parameter_name" $parameter_value
					}
				}

				set url_subpath [string map $template_mapping $url_subpath]
			}

			set url "$server_addr$url_subpath"

			if  {[llength $json_specification_of_parameters] != 0} {
				set query [compile_to_json $json_specification_of_parameters $command_parameters]
			} else {
				if  {$http_method eq "POST"} {
					set query {{}}
				} else {
					set query {}
				}
			}

			my DoRequest $url $http_method $query
		}

		method DoRequest {url {http_method "GET"} {query ""}} {

			# store current settings
			set previous_settings [::http::config]

			# content and accept headers must be set to "application/json"
			::http::config -accept application/json -useragent $user_agent

			set http_request [list ::http::geturl $url -method $http_method]

			if  {$query ne ""} {
				set query [encoding convertto "utf-8" $query]
				lappend http_request -type "application/json;charset=UTF-8" -query $query
                
                
			}

			try {
				# send request
				if { [ catch { set token [eval $http_request]} msg ]} {
					error "error while dispatching request: $msg"
				}

				set response [my ProcessResponse $token]
			} finally {
				# delete http session token
				if {[info exists token]} {
					::http::cleanup $token
				}
				#restore previous configuration
				::http::config {*}$previous_settings
			}

			return $response
		}

		method ProcessResponse {token} {
            # Accept a http token an returns a list "status_response" and "JSON answer".

			upvar #0 $token state

			set http_status [::http::ncode $token]
			set headers		[::http::meta  $token]
            set data		[::http::data  $token]

			if {$http_status >= 300 && $http_status < 304 } {
				foreach {header value} $headers {
					if [string match -nocase $header location] {
						return [my DoRequest $value]
					}
				}

			}

            if {399 < $http_status && $http_status <= 500} {
				set data [string trim [encoding convertfrom "utf-8" $data]]

				if {[catch {set json_answer [json_to_tcl $data]}]} {

					return [list $::selenium::RESPONSE_ERROR [dict create status $http_status html $data]]
				} else {
					return [list $::selenium::RESPONSE_ERROR $json_answer]
				}
			}

            set content_is_an_image no
            foreach content_type [split $state(type) ;] {
                if {[string first $content_type "image/png"] == 0} {
                    set content_is_an_image yes
                    break
                }
            }

            if {$content_is_an_image} {
                return [list $::selenium::RESPONSE_SUCCESS [dict create value [string trim $data]]]
            } else {

                set data [encoding convertfrom "utf-8" $data]
                if [catch {set json_answer [json_to_tcl $data]}] {

                    if {$http_status >= 200 && $http_status < 300 } {
                        set status $::selenium::RESPONSE_SUCCESS
                    } else {
                        set status $::selenium::RESPONSE_ERROR
                    }
                    return [list $status [string trim $data]]
                } else {

                    if {![dict exists $json_answer value]} {
                        dict set json_answer value ""
                    }

                    if {[dict exists $json_answer status] && [dict get $json_answer status] != 0} {
                        set status $::selenium::RESPONSE_ERROR
                    } else {
                        set status $::selenium::RESPONSE_SUCCESS
                    }

                    return [list $status $json_answer]
                }
            }
		}

	}
}
