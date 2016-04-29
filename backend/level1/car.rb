class Car

  attr_accessor :id, :price_per_day, :price_per_km

  def initialize(attrs = {})
    @id = attrs["id"]
    @price_per_day = attrs["price_per_day"]
    @price_per_km = attrs["price_per_km"]
  end

end
