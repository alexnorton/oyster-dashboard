require 'sinatra/activerecord'

class Journey < ActiveRecord::Base
  validates :start_time, presence: true
  validates :cost, presence: true
end
