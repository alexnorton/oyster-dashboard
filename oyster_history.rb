require 'mechanize'
require 'csv'
require 'date'

require 'yaml'

class OysterHistory

  SEARCH_RANGE = 60 # days

  attr_accessor :events

  def initialize
    @events = []
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

  def parse_csv_data(csv_data)

    headers = ['date', 'start time', 'end time', 'action', 'charge', 'credit', 'balance', 'note']

    data = (CSV.parse(csv_data, headers: headers))

    puts data.class

    @events.push data
  end

end
