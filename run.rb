require './oyster_history'

config = YAML.load_file('config.yml')

history = OysterHistory.new

history.fetch_from_web(config['tfl_username'], config['tfl_password'])

puts history.events
