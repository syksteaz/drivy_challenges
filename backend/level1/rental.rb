class Rental

  attr_accessor :id, :car_id, :start_date, :end_date, :nb_of_days, :distance

  def initialize(attrs = {})
    @id = attrs["id"]
    @car_id = attrs["car_id"]
    @start_date = Date.parse(attrs["start_date"]).mjd
    @end_date = Date.parse(attrs["end_date"]).mjd
    @distance = attrs["distance"]
    @nb_of_days = @end_date - @start_date + 1
  end
end

