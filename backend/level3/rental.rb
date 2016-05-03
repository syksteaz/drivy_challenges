class Rental
  attr_accessor :id, :car_id, :start_date, :end_date, :length, :distance, :price

  def initialize(rental_data)
    @id = rental_data["id"]
    @car_id = rental_data["car_id"]
    @start_date = Date.parse(rental_data["start_date"]).mjd
    @end_date = Date.parse(rental_data["end_date"]).mjd
    @length = Date.parse(rental_data["end_date"]).mjd - Date.parse(rental_data["start_date"]).mjd + 1
    @distance = rental_data["distance"]
    # set_total_price
    # ici mettre un @total_price plutôt que de le calculer plus tard
  end

  # def set_total_price

  #   @total_price = ???
  # end

  def compute_rental_price(car_price_per_km, car_price_per_day)
    (compute_rental_price_distance_component(car_price_per_km) +
    compute_rental_price_time_component(car_price_per_day, self.length).to_i).to_i
  end

  def compute_rental_price_distance_component(car_price_per_km)
    self.distance * car_price_per_km
  end

  def compute_rental_price_time_component(car_price_per_day, rental_length)
    price_per_day = car_price_per_day
    price_per_day_discounted_by_10 = price_per_day * 0.9
    price_per_day_discounted_by_30 = price_per_day * 0.7
    price_per_day_discounted_by_50 = price_per_day * 0.5
    discount_by_10_min_threshold = 1
    discount_by_10_max_threshold = 4
    discount_by_30_min_threshold = 4
    discount_by_30_max_threshold = 10
    discount_by_50_min_threshold = 10

    days_at_full_price = rental_length >= 1 ? 1 : rental_length
    days_at_10_discount = rental_length > discount_by_10_max_threshold ? (discount_by_10_max_threshold -
      discount_by_10_min_threshold ) : ( rental_length - discount_by_10_min_threshold )
    days_at_30_discount = rental_length > discount_by_30_max_threshold ? (discount_by_30_max_threshold -
      discount_by_30_min_threshold ) : ( rental_length - discount_by_30_min_threshold )
    days_at_50_discount = rental_length > discount_by_50_min_threshold ? (rental_length -
      discount_by_50_min_threshold ) : 0

    full_price_component = (days_at_full_price > 0 ? days_at_full_price : 0) * price_per_day
    price_discount_by_10_component = (days_at_10_discount > 0 ? days_at_10_discount : 0) * price_per_day_discounted_by_10
    price_discount_by_30_component = (days_at_30_discount > 0 ? days_at_30_discount : 0) * price_per_day_discounted_by_30
    price_discount_by_50_component = (days_at_50_discount > 0 ? days_at_50_discount : 0) * price_per_day_discounted_by_50
    full_price_component.to_i +
    price_discount_by_10_component.to_i +
    price_discount_by_30_component.to_i +
    price_discount_by_50_component.to_i
  end
end
