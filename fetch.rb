require 'gmail'
require 'yaml'
require 'csv'
require 'terminal-table'

config = YAML.load_file('config.yml')

gmail = Gmail.new(config['username'], config['password'])

emails = gmail.inbox.emails(:from => "autoresponse@tfl.gov.uk", :subject => "Oyster Journey History Statement")

data = []

emails.each do |email|
  email.message.attachments.each do |attachment|
    data.concat (CSV.parse(attachment.decoded)[2..-1]).reverse
  end
end

puts Terminal::Table.new \
  :headings => ['Date', 'Start Time', 'End Time', 'Journey/Action', 'Charge', 'Credit', 'Balance', 'Note'], \
  :rows => data