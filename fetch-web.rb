require 'mechanize'
require 'yaml'
require 'csv'
require 'terminal-table'
require 'date'

SEARCH_RANGE = 60 # days

config = YAML.load_file('config.yml')

agent = Mechanize.new do |agent|
  agent.user_agent_alias = 'Mac Safari'
end

agent.get('https://account.tfl.gov.uk/oyster/login') do |login_page|

  login_page.form_with(:name => 'sign-in') do |form|
    form['UserName'] = config['tfl_username']
    form['Password'] = config['tfl_password']
  end.submit

  journey_history_page = agent.post('https://oyster.tfl.gov.uk/oyster/journeyHistory.do', {
    :dateRange => 'custom date range',
    :csDateFrom => (Date.today - SEARCH_RANGE).strftime('%d/%m/%Y'),
    :csDateTo => Date.today.strftime('%d/%m/%Y')
  })

  csv_link = journey_history_page.links_with(:text => /Download CSV format/)[0]

  csv_path = csv_link.attributes['onclick'].match(/document.jhDownloadForm.action="(.*?)";/)[1]

  csv_page = agent.get('https://oyster.tfl.gov.uk' + csv_path)

  data = (CSV.parse(csv_page.body))[2..-1]

  puts Terminal::Table.new \
    :headings => ['Date', 'Start Time', 'End Time', 'Journey/Action', 'Charge', 'Credit', 'Balance', 'Note'], \
    :rows => data

end
