require 'sinatra/activerecord'

class Location < ActiveRecord::Base
  validates :name, presence: true
end
