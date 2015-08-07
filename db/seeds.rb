filename = File.dirname(__FILE__) + '/seeds.json'

exit unless File.exists? filename

data = JSON.parse(File.read(filename), symbolize_names: true)

locations = Hash.new

data[:locations].each do |location|
  locations[location[:id]] = Location.find_or_create_by(name: location[:name])
end

data[:journeys].each do |journey|
  case journey[:type]
  when 'RailJourney'
    RailJourney.create(
      from: locations[journey[:from_id]],
      to: locations[journey[:to_id]],
      start_time: DateTime.parse(journey[:start_time]),
      end_time: DateTime.parse(journey[:end_time]),
      cost: journey[:cost]
    )
  when 'BusJourney'
    BusJourney.create(
      start_time: DateTime.parse(journey[:start_time]),
      route: journey[:route],
      cost: journey[:cost]
    )
  end
end