require 'rubygems'
require 'sinatra'
require 'haml'
require 'hashie'
require 'forecast_io'
require 'thin'
require 'geocoder'

Geocoder.configure(:timeout => 60)

Forecast::IO.configure do |configuration|
  configuration.api_key = '4b995d1de905a82469d842537d4039e2'
end

get '/' do
  
	result = request.location
	@lat = result.latitude
	@long = result.longitude

	city = request.location.city
	@city = city
	  
	forecast = Forecast::IO.forecast(@lat, @long)
	@current_temp = (forecast.currently.temperature)
	@current_wind = (forecast.currently.windSpeed).ceil
	@current_icon = forecast.currently.icon
	@current_clouds = forecast.currently.cloudCover

	yesterday = Forecast::IO.forecast(@lat, @long, time: (Time.new.to_i - 86400))
	@yesterday_temp = (yesterday.currently.temperature)
	@yesterday_wind = (yesterday.currently.windSpeed)
	@yesterday_clouds = yesterday.currently.cloudCover

	soon = Forecast::IO.forecast(@lat, @long, time: (Time.new.to_i + 3600))
	@temp_soon = (soon.currently.temperature)

	@soon_description = "it'll be warmer an hour from now."
		if @temp_soon < @current_temp
			@soon_description = "it'll be cooler an hour from now."
		end


	@temp_difference = (@current_temp - @yesterday_temp).ceil
	@temp_difference_abs = @temp_difference.abs	
	@wind_difference = (((@current_wind - @yesterday_wind)/@yesterday_wind)*100)
	@cloud_difference = (((@current_clouds - @yesterday_clouds)/@yesterday_clouds)*100)

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

	@cloud_description = "no brighter or cloudier than"
		if (@cloud_difference >= 0 && @cloud_difference <= 25)
			@cloud_description = "a bit cloudier than"
		elsif (@cloud_difference > 25 && @cloud_difference <= 75)
			@cloud_description = "much more cloudy than"
		elsif (@cloud_difference > 75)
			@cloud_description = "disgustingly cloudy compared to"
		elsif (@cloud_difference < 0 && @cloud_difference >= -25)
			@cloud_description = "a bit clearer than"
		elsif (@cloud_difference < -25 && @cloud_difference >= -75)
			@cloud_description = "way clearer than"
		elsif (@cloud_difference < -75)
			@cloud_description = "incredibly clear compared to"	
		end
	
	@unit = "degrees"
		if @temp_difference == 1 || @temp_difference == -1
			@unit = "degree"
		end
		
		haml :index
end