require_relative 'journey'

class RailJourney < Journey
  validates :end_time, presence: true
  validates :from, presence: true
  validates :to, presence: true

  belongs_to :from, class_name: 'Location'
  belongs_to :to, class_name: 'Location'
end