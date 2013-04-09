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
	@current_temp = (((forecast.currently.temperature)-32)*(5.0/9.0))
	@current_wind = ((forecast.currently.windSpeed) * 1.609344).ceil
	@current_icon = forecast.currently.icon
	@current_clouds = forecast.currently.cloudCover

	yesterday = Forecast::IO.forecast(@lat, @long, time: (Time.new.to_i - 86400))
	@yesterday_temp = (((yesterday.currently.temperature)-32)*(5.0/9.0)).ceil
	@yesterday_wind = ((yesterday.currently.windSpeed) * 1.609344).ceil
	@yesterday_clouds = yesterday.currently.cloudCover

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
			@cloud_description = "a bit brighter than"
		elsif (@cloud_difference > 25 && @cloud_difference <= 75)
			@cloud_description = "way brighter than"
		elsif (@cloud_difference > 75)
			@cloud_description = "a much more beautiful day than"
		elsif (@cloud_difference < 0 && @cloud_difference >= -25)
			@cloud_description = "a bit cloudier"
		elsif (@cloud_difference < -25 && @cloud_difference >= -75)
			@cloud_description = "way cloudier than"
		elsif (@cloud_difference < -75)
			@cloud_description = "not even as close to as nice as"	
		end
	
	@unit = "degrees"
		if @temp_difference == 1 || @temp_difference == -1
			@unit = "degree"
		end
		
		haml :index
end