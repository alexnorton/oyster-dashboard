require 'mechanize'
require 'csv'
require 'date'
require 'yaml'
require_relative 'model/rail_journey'
require_relative 'model/location'

class OysterHistory

  SEARCH_RANGE = 60 # days

  attr_accessor :events, :journeys, :locations

  def initialize
    @events = []
    @journeys = []
    @locations = []
  end

  def fetch_from_web(username, password)
    agent = Mechanize.new do |agent|
      agent.user_agent_alias = 'Mac Safari'
    end

    agent.get('https://account.tfl.gov.uk/oyster/login') do |login_page|
      login_page.form_with(:name => 'sign-in') do |form|
        form['UserName'] = username
        form['Password'] = password
      end.submit

      journey_history_page = agent.post('https://oyster.tfl.gov.uk/oyster/journeyHistory.do', {
        :dateRange => 'custom date range',
        :csDateFrom => (Date.today - SEARCH_RANGE).strftime('%d/%m/%Y'),
        :csDateTo => Date.today.strftime('%d/%m/%Y')
      })

      csv_link = journey_history_page.links_with(:text => /Download CSV format/)[0]
      csv_path = csv_link.attributes['onclick'].match(/document.jhDownloadForm.action="(.*?)";/)[1]
      csv_page = agent.get('https://oyster.tfl.gov.uk' + csv_path)

      parse_csv_data(csv_page.body)
    end
  end

  def fetch_from_dir(dirname)
    Dir.foreach(dirname) do |filename|
      unless filename[0] == '.'
        fetch_from_file(dirname + '/' + filename)
      end
    end
  end

  def fetch_from_file(filename)
    file = File.read(filename)

    parse_csv_data(file)
  end

  def parse_csv_data(csv_data)
    headers = ['date', 'start time', 'end time', 'action', 'charge', 'credit', 'balance', 'note']

    # Drop the first two lines of the CSV file
    csv_data = csv_data.lines.to_a[2..-1].join

    data = CSV.parse(csv_data, headers: headers, :header_converters => :symbol, :converters => :all) do |row|
      @events.push(row.to_hash)
    end
  end

  def get_location(name)
    # Strip () or [] brackets after name
    name = name.match(/^(.*?)( (\(.*?\)|\[.*?\]))?$/)[1]
    
    unless location = @locations.find{|location| location.name == name}
      location = Location.new(name)
      @locations.push(location)
    end

    location
  end

  def parse_events(events)
    events.each do |event|
      match = /^(.*?) to (.*?)$/.match(event[:action])

      if(event[:start_time] && event[:end_time] && match)

        from = match[1]
        to   = match[2]

        @journeys.push RailJourney.create(
          from: Location.find_or_create_by(name: from),
          to: Location.find_or_create_by(name: to),
          start_time: DateTime.parse(event[:start_time] + ' ' + event[:date]),
          end_time: DateTime.parse(event[:end_time] + ' ' + event[:date]),
          cost: event[:charge]
        )
      end
    end
  end
end
