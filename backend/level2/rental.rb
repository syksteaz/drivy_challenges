class Rental
  attr_accessor :id, :car_id, :distance, :start_date, :end_date, :nb_of_days, :total_price

  DISCOUNT_BY_10_MIN_THRESHOLD = 1
  DISCOUNT_BY_30_MIN_THRESHOLD = 4
  DISCOUNT_BY_50_MIN_THRESHOLD = 10
  MAX = 1000

  def initialize(rental = {}, car)
    @id = rental['id']
    @car_id = rental['car_id']
    @distance = rental['distance']
    @start_date = Date.parse(rental['start_date'])
    @end_date = Date.parse(rental['end_date'])
    @nb_of_days = end_date - start_date + 1
    @total_price = computation_of_total_price(car)
  end

  def computation_of_total_price(car)
    (self.computation_of_price_distance_component(car) +
    self.computation_of_price_time_component(car)).to_i
  end

  def computation_of_price_distance_component(car)
    @distance * car.price_per_km
  end

  def computation_of_price_time_component(car)
    self.compute_discounted_price(car, compute_nb_of_days_at_each_price)
  end

  def compute_discounted_price(car, count_of_nb_of_days_at_each_price)
    count_of_nb_of_days_at_each_price[0][:full_price] * car.price_per_day +
    count_of_nb_of_days_at_each_price[0][:discount_10] * car.price_per_day * 0.9 +
    count_of_nb_of_days_at_each_price[0][:discount_30] * car.price_per_day * 0.7 +
    count_of_nb_of_days_at_each_price[0][:discount_50] * car.price_per_day * 0.5
  end

  def compute_nb_of_days_at_each_price
    count_of_nb_of_days_at_each_price = []
    nb_of_days_at_each_price_detail = {}
    if self.nb_of_days >= DISCOUNT_BY_10_MIN_THRESHOLD
      nb_of_days_at_each_price_detail[:full_price] = 1
    else
      nb_of_days_at_each_price_detail[:full_price] = self.nb_of_days
    end
    self.nb_of_days_at_price_loop(DISCOUNT_BY_10_MIN_THRESHOLD, DISCOUNT_BY_30_MIN_THRESHOLD, nb_of_days_at_each_price_detail, :discount_10 )
    self.nb_of_days_at_price_loop(DISCOUNT_BY_30_MIN_THRESHOLD, DISCOUNT_BY_50_MIN_THRESHOLD, nb_of_days_at_each_price_detail, :discount_30 )
    self.nb_of_days_at_price_loop(DISCOUNT_BY_50_MIN_THRESHOLD, MAX, nb_of_days_at_each_price_detail, :discount_50 )
    count_of_nb_of_days_at_each_price << nb_of_days_at_each_price_detail
  end

  def nb_of_days_at_price_loop(min_threshold, max_threshold, hash_name, symbol_for_hash)
    if self.nb_of_days <= min_threshold
      hash_name[symbol_for_hash] = 0
    elsif self.nb_of_days > max_threshold
      hash_name[symbol_for_hash] = max_threshold - min_threshold
    else
      hash_name[symbol_for_hash] = self.nb_of_days - min_threshold
    end
  end
end
