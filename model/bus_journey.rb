require_relative 'journey'

class BusJourney < Journey
  validates :route, presence: true
end