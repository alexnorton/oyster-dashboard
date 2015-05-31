require 'sinatra/base'
require 'sinatra/activerecord'
require_relative 'helpers/oyster_history_parser'
require_relative 'model/location'
require_relative 'model/rail_journey'


class Public < Sinatra::Base

  register Sinatra::ActiveRecordExtension

  get '/data.json' do
    {
      locations: Location.all,
      journeys: RailJourney.all
    }.to_json
  end

end

class Import < Sinatra::Base

  helpers Sinatra::OysterHistoryParser

  register Sinatra::ActiveRecordExtension

  use Rack::Auth::Basic, 'protected' do |username, password|
    (ENV['IMPORT_USERNAME'] && ENV['IMPORT_PASSWORD'] \
        && username == ENV['IMPORT_USERNAME'] && password == ENV['IMPORT_PASSWORD']) \
      || (username == 'test' && password == 'test' && Sinatra::Base.development?)
  end

  post '/' do

    error 400, 'No attachments found' unless params['attachments']

    csv_files = params['attachments'].values.select do |attachment|
      /\.csv$/.match(attachment[:filename])
    end

    error 400, 'No CSV files found' unless csv_files.length > 0

    journeys = []

    csv_files.each do |csv_file|
      journeys.concat parse_oyster_csv csv_file[:tempfile]
    end

    journeys.to_json
  end

end