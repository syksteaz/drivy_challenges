class Car
  # the Car class aims at creating a new car
  attr_accessor :id, :price_per_day, :price_per_km

  def initialize(car_data)
    @id = car_data.first["id"]
    @price_per_day = car_data.first["price_per_day"]
    @price_per_km = car_data.first["price_per_km"]
  end
end
