require 'sinatra'
require 'sinatra/activerecord'
require_relative 'oyster_history'
require_relative 'model/location'
require_relative 'model/rail_journey'


class App < Sinatra::Base
  register Sinatra::ActiveRecordExtension

  puts ActiveRecord::Base.connection_config

  set :server, 'thin'
  
  get '/data.json' do
    # history = OysterHistory.new
    #
    # history.fetch_from_dir('input')
    #
    # history.parse_events(history.events)
    #
    # history.locations.to_json
    
    {
      locations: Location.all,
      journeys: RailJourney.all
    }.to_json
  end
  
end