require 'rubygems'
require 'sinatra'
require 'haml'
require 'hashie'
require 'forecast_io'
require 'shotgun'
require 'geocoder'

Geocoder.configure(:timeout => 15)

Forecast::IO.configure do |configuration|
  configuration.api_key = 'fe6fa0b5700a6134723fabdb8a08b296'
end

get '/' do
  
	result = request.location
	@lat = result.latitude
	@long = result.longitude

	city = request.location.city
	@city = city
	  
	forecast = Forecast::IO.forecast(@lat, @long)
	@current_temp = (((forecast.currently.temperature)-32)*(5.0/9.0)).ceil
	@current_wind = ((forecast.currently.windSpeed) * 1.609344).ceil

	yesterday = Forecast::IO.forecast(@lat, @long, time: (Time.new.to_i - 86400))
	@yesterday_temp = (((yesterday.currently.temperature)-32)*(5.0/9.0)).ceil
	@yesterday_wind = ((yesterday.currently.windSpeed) * 1.609344).ceil

	@temp_difference = (@current_temp - @yesterday_temp).ceil	
	@wind_difference = (@current_wind - @yesterday_wind)

	@temp_description = "warmer"
		if @temp_difference < 0
			@temp_description = "colder"
		end

	@wind_description = "you dont need to worry about the wind"
		if (@wind_difference >= 0 && @wind_difference <= 50)
			@wind_description = "a bit windier"
		elsif (@wind_difference > 50 && @wind_difference <= 100)
			@wind_description = "noticeably windier"
		elsif (@wind_difference > 100)
			@wind_description = "much more windy"
		elsif (@wind_difference <= 0 && @wind_difference >= -50)
			@wind_description = "a bit less windy"
		elsif (@wind_difference < -50 && @wind_difference >= -100)
			@wind_description = "noticeably less windy"
		elsif (@wind_difference < -100)
			@wind_description = "way less windy"
		end

	@unit = "degree"
		unless @temp_difference == 1 || @temp_difference == -1
			@unit = "degrees"
		end
		
		haml :index
end