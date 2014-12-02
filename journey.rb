class Journey
  attr_accessor :from, :to, :start_time, :end_time

  def initialize(from, to, start_time, end_time)
    @from = from
    @to = to
    @start_time = start_time
    @end_time = end_time
  end
end
