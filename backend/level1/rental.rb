class Rental

  attr_accessor :id, :car_id, :start_date, :end_date, :distance, :nb_of_days, :total_price

  def initialize(attrs = {}, car)
    @id = attrs['id']
    @car_id = car.id
    @start_date = Date.parse(attrs['start_date'])
    @end_date = Date.parse(attrs['end_date'])
    @distance = attrs['distance']
    @nb_of_days = (@end_date - @start_date + 1).to_i
    @total_price = @nb_of_days * car.price_per_day + @distance * car.price_per_km
  end
end
