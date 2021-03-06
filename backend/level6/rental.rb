class Rental
  attr_accessor :id, :car_id, :distance, :start_date, :end_date, :nb_of_days, :total_price, :is_deductible_reduction, :deductible_reduction_amount

  DISCOUNT_BY_10_MIN_THRESHOLD = 1
  DISCOUNT_BY_30_MIN_THRESHOLD = 4
  DISCOUNT_BY_50_MIN_THRESHOLD = 10
  MAX = 1000
  DEDUCTIBLE_REDUCTION_PRICE_PER_DAY = 400


  def initialize(rental = {}, car)
    @id = rental['id']
    @car_id = rental['car_id']
    @distance = rental['distance']
    @start_date = Date.parse(rental['start_date']).mjd
    @end_date = Date.parse(rental['end_date']).mjd
    @nb_of_days = end_date - start_date + 1
    @total_price = computation_of_total_price(car)
    @is_deductible_reduction = rental['deductible_reduction']
    @deductible_reduction_amount = compute_deductible_reduction_amount(@nb_of_days, @is_deductible_reduction)
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

  def compute_deductible_reduction_amount(rental_length, is_deductible_reduction)
    is_deductible_reduction ? (rental_length * DEDUCTIBLE_REDUCTION_PRICE_PER_DAY) : 0
  end

  def compute_who_owe_what(commission)
    who_owe_what_results = []
    list_of_amounts =
    {
      driver: self.total_price + self.deductible_reduction_amount,
      owner: (self.total_price * 0.7).to_i,
      insurance: commission.insurance_fee,
      assistance: commission.roadside_assistance_fee,
      drivy: (commission.drivy_fee + self.deductible_reduction_amount).to_i
    }

    %w(driver owner insurance assistance drivy).each do |actor|
      hash_of_results = {}
      hash_of_results['who'] = actor
      if actor == 'driver'
        hash_of_results['type'] = 'debit'
      else
        hash_of_results['type'] = 'credit'
      end
      hash_of_results['amount'] = list_of_amounts[actor.to_sym]
      who_owe_what_results << hash_of_results
    end
    return who_owe_what_results
  end

  def compute_change_actions(old_rental, new_rental, car)
    old_actions = old_rental.compute_who_owe_what(Commission.new(old_rental))
    new_actions = new_rental.compute_who_owe_what(Commission.new(new_rental))

    change_actions = []
    new_actions.each do |new_action|
      old_action = old_actions.select { |k| k['who'] == new_action['who'] }.first
      rental_modification_amount = new_action['amount'] - old_action['amount']
      each_action_result = { 'who'=> new_action['who'] }
      if rental_modification_amount < 0.0
        each_action_result['who'] != 'driver' ? each_action_result['type'] = 'debit' : each_action_result['type'] = 'credit'
      elsif rental_modification_amount > 0.0
        each_action_result['who'] != 'driver' ? each_action_result['type'] = 'credit' : each_action_result['type'] = 'debit'
      end
      each_action_result['amount'] = rental_modification_amount.abs
      change_actions << each_action_result
    end
    return change_actions
  end


  def self.build_new_rental_data(old_rental_data, rental_data_modifications)
    new_rental_data = old_rental_data.clone
    old_rental_data.keys.each do |key|
      new_rental_data[key] = rental_data_modifications[key] if rental_data_modifications[key] != nil
    end
    return new_rental_data
  end
end
