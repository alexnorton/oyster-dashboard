require 'awesome_print'
require_relative 'app'
require_relative 'oyster_history'

#config = YAML.load_file('config.yml')

history = OysterHistory.new

history.fetch_from_dir('input')

history.parse_events(history.events)

ap history.journeys, options = {:raw => true}
