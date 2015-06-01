require 'sinatra/base'
require 'csv'
require_relative '../model/bus_journey'
require_relative '../model/rail_journey'
require_relative '../model/location'

module Sinatra
  module OysterHistoryParser

    def parse_oyster_csv(csv_file)
      csv_data = csv_file.read

      headers = ['date', 'start time', 'end time', 'action', 'charge', 'credit', 'balance', 'note']

      # Drop the first two lines of the CSV file
      csv_data = csv_data.lines.to_a[2..-1].join

      journeys = []

      CSV.parse(csv_data, headers: headers, :header_converters => :symbol, :converters => :all) do |row|
        journeys.push process_event(row.to_hash)
      end

      journeys
    end

    private
    def process_event(event)
      
      case event[:action]
        when /^(.+?)(?: (?:\[.+\]|\(.+\)))? to (.+?)(?: (?:\[.+\]|\(.+\)))?$/
          RailJourney.create(
              from: Location.find_or_create_by(name: $1),
              to: Location.find_or_create_by(name: $2),
              start_time: DateTime.parse(event[:start_time] + ' ' + event[:date]),
              end_time: DateTime.parse(event[:end_time] + ' ' + event[:date]),
              cost: event[:charge]
          )
        when /^Bus journey, route (.+)$/
          BusJourney.create(
              start_time: DateTime.parse(event[:start_time] + ' ' + event[:date]),
              route: $1,
              cost: event[:charge]
          )
        else
          nil
      end
      
    end

  end
end