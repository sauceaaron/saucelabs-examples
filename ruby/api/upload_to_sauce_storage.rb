#!/usr/bin/env ruby 
require 'uri'
require 'net/http'
require 'json'

SAUCE_LOCAL_FILE_PATH = ENV["SAUCE_LOCAL_FILE_PATH"]
SAUCE_STORAGE_LOCATION = ENV["SAUCE_STORAGE_LOCATION"]

SAUCE_USERNAME = ENV["SAUCE_USERNAME"]
SAUCE_ACCESS_KEY = ENV["SAUCE_ACCESS_KEY"]
SAUCE_API_URL= "https://saucelabs.com/rest/v1"
SAUCE_STORAGE_ENDPOINT_URL = "#{SAUCE_API_URL}/storage/#{SAUCE_USERNAME}/#{SAUCE_STORAGE_LOCATION}?overwrite=true"

if ! SAUCE_LOCAL_FILE_PATH 
	puts "need to set SAUCE_LOCAL_FILE_PATH"
	exit 1
end

if ! SAUCE_STORAGE_LOCATION
	puts "need to set SAUCE_STORAGE_LOCATION"
	exit 1
end

if ! SAUCE_USERNAME || ! SAUCE_ACCESS_KEY
	puts "need to set SAUCE_USERNAME and SAUCE_ACCESS_KEY"
	exit 1
end

upload_file_binary_content = File.open(SAUCE_LOCAL_FILE_PATH, 'rb') { |io| io.read }

puts "URL: " + SAUCE_STORAGE_ENDPOINT_URL
uri = URI.parse(SAUCE_STORAGE_ENDPOINT_URL)

Net::HTTP.start(uri.host, uri.port, :use_ssl => true) do |http|
	request_headers = { "Content-Type" => "application/octet-stream" }
	request = Net::HTTP::Post.new(uri.request_uri, request_headers)

	request.basic_auth SAUCE_USERNAME, SAUCE_ACCESS_KEY 

	request.body = upload_file_binary_content

	response = http.request request 

	puts response
	puts response.code, response.message

	if response.code != "200"
		puts "failed to upload"
		exit 1
	end

	puts response.body

	result = JSON.parse(response.body)

	puts "sauce storage filename: " + result["filename"]
	puts "sauce storage checksum: " + result["md5"]

end
