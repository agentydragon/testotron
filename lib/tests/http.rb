require 'test'

module Testotron
	module Tests
		class HTTP < Test
			KEY = "http"

			def initialize(host, port = 80, requests = nil)
				if requests.nil?
					requests = "http://#{host}/"
				end
				@host, @port, @requests = host, port, [*requests]
			end

			def human_name
				"HTTP test of #{@host}, port #{@port}, requests #{@requests.join ','}"
			end

			def run(runner)
				runner.report self, "Testing HTTP server on #{@host} port #{@port}..."
				http = Net::HTTP.new(@host, @port)
				http.read_timeout = 2
				http.open_timeout = 2
				@requests.each do |page|
					runner.report self, "Trying #{page}..."
					request = Net::HTTP::Get.new URI.parse(page).request_uri

					begin
						response = http.request(request)
					rescue Timeout::Error
						raise TestFailed, "HTTP connection timed out (Timeout::Error)"
					rescue Errno::ETIMEDOUT
						raise TestFailed, "HTTP connection timed out (ETIMEDOUT)"
					rescue Errno::ECONNREFUSED
						raise TestFailed, "HTTP connection refused (ECONNREFUSED)"
					rescue SocketError
						raise TestFailed, "HTTP connection failed (SocketError)"
					end

					good_codes = 100...400
					code = response.code.to_i
					unless good_codes.include? code
						raise TestFailed, "Response code #{code} on #{@post}:#{@port} GET #{page}"
					end
				end
			end
		end
	end
end
