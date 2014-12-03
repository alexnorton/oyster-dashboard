require 'sinatra'
require './oyster_history'


class App < Sinatra::Base
  
  set :server, 'thin'
  
  
  get '/data.json' do
    history = OysterHistory.new
    
    history.fetch_from_dir('input')
    
    history.parse_events(history.events)
    
    history.locations.to_json
    
    {
      locations: history.locations.map {|location|
        {
          name: location.name
        }
      },
      journeys: history.journeys.map {|journey|
        {
          source: history.locations.find_index(journey.from),
          target: history.locations.find_index(journey.to),
          value: 1
        }
      }
    }.to_json
  end
  
end