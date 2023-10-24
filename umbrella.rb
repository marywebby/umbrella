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

# PIRATE WEATHER DATA NOW 
pirate_url = "https://api.pirateweather.net/forecast/" + ENV.fetch("PIRATE_WEATHER_KEY") + "/" + latitude.to_s + "," + longitude.to_s

# GETTING THE PIRATE WEATHER DATA AND PARSING IT 
require "http"

pirate_res = HTTP.get(pirate_url)

raw_pirate_response = pirate_res.to_s

require ("json")

parsed_pirate_weather_data = JSON.parse(raw_pirate_response)

# GETTING THE CURRENT TEMP
currently_hash = parsed_pirate_weather_data.fetch("currently")

current_temp = currently_hash.fetch("temperature")

puts "It is currently #{current_temp}°F."

# Some locations around the world do not come with minutely data.
minutely_hash = parsed_pirate_weather_data.fetch("minutely", false)

if minutely_hash
  next_hour_summary = minutely_hash.fetch("summary")

  puts "Next hour: #{next_hour_summary}"
end

# NOW WE ARE LOOKING INTO THE NEXT 12 HOURS OF WEATHER 
hourly_hash = parsed_pirate_weather_data.fetch("hourly")

hourly_data_array = hourly_hash.fetch("data")

next_twelve_hours = hourly_data_array[1..12]

# SETTING THE PERCIPITATION TO FALSE AND THE THRESHOLD 
precip_prob_threshold = 0.10

any_precipitation = false

# CREATING THE STRING TO STATE WHEN RAIN STARTS
next_twelve_hours.each do |hour_hash|
  # GETTING THE PERCIP PROBIBILITY FROM API IN THE HOURS HASH
  precip_prob = hour_hash.fetch("precipProbability")

  # IF THE PRECIP PROBIBILITY IS LARGER THAN THE THRESHOLD WE SET EARLIER (.10) THEN WE WILL RESET ANY_PRECIP = TO TRUE
  if precip_prob > precip_prob_threshold
    any_precipitation = true

    # WE ARE FETCHING THE TIME IN WHICH PRECIP WILL HAPPEN
    precip_time = Time.at(hour_hash.fetch("time"))

    # USING MATH TO FIGURE OUT HOW LONG THAT IS FROM THE CURRENT TIME NOW
    seconds_from_now = precip_time - Time.now

    # DIVING BY MINUTES THEN SECONDS
    hours_from_now = seconds_from_now / 60 / 60

    # PP THE STRING TO SAY HOW MANY HOURS FROM NOW THERE IS A _% CHANCE OF RAIN
    puts "In #{hours_from_now.round} hours, there is a #{(precip_prob * 100).round}% chance of precipitation."
  end
end

# IF THE PRECIP IS SET TO TRUE, WHICH WE CHANGED EARLIER BECAUSE THE THRESHOLD WENT OVER, WE WILL SAY IF YOU NEED AN UMBRELLA
if any_precipitation == true
  puts "You might want to take an umbrella!"
else
  puts "You probably won't need an umbrella."
end

