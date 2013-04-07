require 'rubygems'
require 'sinatra'
require 'Haml'
require 'hashie'
require 'forecast_io'
require 'shotgun'
require 'geocoder'


Forecast::IO.configure do |configuration|
  configuration.api_key = '79f7c17463bf2fc25b89cd3ea8f7cd51'
end



get '/' do


result = request.location

@long = result.longitude
@lat = result.latitude



forecast = Forecast::IO.forecast(45.5,73.5)
@current_temp = forecast.currently.temperature
@current_wind = forecast.currently.windSpeed

yesterday = Forecast::IO.forecast(45.5,73.5, time: (Time.new.to_i - 86400))
@yesterday_temp = yesterday.currently.temperature
@yesterday_wind = yesterday.currently.windSpeed

@temp_difference = (@current_temp - @yesterday_temp).to_i
@wind_difference = (((@current_wind - @yesterday_wind)/@yesterday_wind)*100).to_i

@temp_description = "warmer"
	if @temp_difference < 0
		@temp_description = "colder"
	end

@wind_description = "you dont need to worry about the wind"
	if (@wind_difference >= 0 && @wind_difference <= 5)
		@wind_description = "a bit windier"
	elsif (@wind_difference > 5 && @wind_difference <= 10)
		@wind_description = "noticeably windier"
	elsif (@wind_difference > 15)
		@wind_description = "much more windy"
	elsif (@wind_difference <= 0 && @wind_difference >= -5)
		@wind_description = "a bit less windy"
	elsif (@wind_difference < -5 && @wind_difference >= -10)
		@wind_description = "noticeably less windy"
	elsif (@wind_difference < -15)
		@wind_description = "way less windy"
	end
	
	haml :index

end