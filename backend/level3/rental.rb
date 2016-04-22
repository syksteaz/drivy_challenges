class Rental
  attr_accessor :id, :car_id, :start_date, :end_date, :length, :distance, :price

  def initialize(rental_data)
    @id = rental_data["id"]
    @car_id = rental_data["car_id"]
    @start_date = Date.parse(rental_data["start_date"]).mjd
    @end_date = Date.parse(rental_data["end_date"]).mjd
    @length = Date.parse(rental_data["end_date"]).mjd - Date.parse(rental_data["start_date"]).mjd + 1
    @distance = rental_data["distance"]
  end

  def compute_rental_price(car_price_per_km, car_price_per_day)
    (compute_rental_price_distance_component(car_price_per_km) +
    compute_rental_price_time_component(car_price_per_day)).to_i
  end

  def compute_rental_price_distance_component(car_price_per_km)
    self.distance * car_price_per_km
  end

  def compute_rental_price_time_component(car_price_per_day)
    price_per_day = car_price_per_day
    price_per_day_discounted_by_10 = price_per_day * 0.9
    price_per_day_discounted_by_30 = price_per_day * 0.7
    price_per_day_discounted_by_50 = price_per_day * 0.5

    if self.length == 1
      nb_day_at_full_price = 1
      total_price_time_component = nb_day_at_full_price * price_per_day
    elsif self.length.between?(1,4)
      nb_day_at_full_price = 1
      nb_day_at_price_discounted_by_10 = self.length - 1
      total_price_time_component = nb_day_at_full_price * price_per_day +
      nb_day_at_price_discounted_by_10 * price_per_day_discounted_by_10
    elsif self.length.between?(4,10)
      nb_day_at_full_price = 1
      nb_day_at_price_discounted_by_10 = 3
      nb_day_at_price_discounted_by_30 = self.length -
      (nb_day_at_full_price + nb_day_at_price_discounted_by_10)
      total_price_time_component = nb_day_at_full_price * price_per_day +
      nb_day_at_price_discounted_by_10 * price_per_day_discounted_by_10 +
      nb_day_at_price_discounted_by_30 * price_per_day_discounted_by_30
    elsif self.length > 11
      nb_day_at_full_price = 1
      nb_day_at_price_discounted_by_10 = 3
      nb_day_at_price_discounted_by_30 = 6
      nb_day_at_price_discounted_by_50 = self.length -
      (nb_day_at_full_price + nb_day_at_price_discounted_by_10 +
        nb_day_at_price_discounted_by_30)
      total_price_time_component = nb_day_at_full_price * price_per_day +
      nb_day_at_price_discounted_by_10 * price_per_day_discounted_by_10 +
      nb_day_at_price_discounted_by_30 * price_per_day_discounted_by_30 +
      nb_day_at_price_discounted_by_50 * price_per_day_discounted_by_50
    end
  end
end
