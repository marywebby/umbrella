# api_key = ENV.fetch('PRIVATE_KEY')
pp "howdy"

pp "Where are you located?"

user_location = gets.chomp.gsub(" ", "%20")

# user_location = "Chicago"

pp user_location

maps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=" + user_location + "&key=" + ENV.fetch("GMAPS_KEY")

require "http"

resp = HTTP.get(maps_url)

raw_response = resp.to_s 

require "json"

parsed_response = JSON.parse(raw_response)

results = parsed_response.fetch("results")

first_result = results.at(0)

geo = first_result.fetch("geometry")

loc = geo.fetch("location")

latitude = loc.fetch("lat")

longitude = loc.fetch("lng")

pp latitude
pp longitude
