class Rental
  attr_accessor :id, :car_id, :start_date, :end_date, :length, :distance, :price, :is_deductible_reduction, :deductible_reduction_amount

  def initialize(rental_data)
    @id = rental_data["id"]
    @car_id = rental_data["car_id"]
    @start_date = Date.parse(rental_data["start_date"]).mjd
    @end_date = Date.parse(rental_data["end_date"]).mjd
    @length = Date.parse(rental_data["end_date"]).mjd - Date.parse(rental_data["start_date"]).mjd + 1
    @distance = rental_data["distance"]
    @is_deductible_reduction = rental_data["deductible_reduction"]
  end

  def compute_rental_price(car_price_per_km, car_price_per_day)
    self.price = (compute_rental_price_distance_component(car_price_per_km) +
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
    price = full_price_component.to_i +
    price_discount_by_10_component.to_i +
    price_discount_by_30_component.to_i +
    price_discount_by_50_component.to_i
  end

  def compute_deductible_reduction_amount(rental_length, is_deductible_reduction)
    deductible_reduction_price_per_day = 400
    is_deductible_reduction ? (rental_length * deductible_reduction_price_per_day) : 0
  end

  def compute_who_owe_what(list_of_commissions, deductible_reduction_amount)
    who_owe_what_results = []
    list_of_amounts = {
      driver: self.price + deductible_reduction_amount,
      owner: (self.price * 0.7).to_i,
      insurance: list_of_commissions["insurance_fee"],
      assistance: list_of_commissions["assistance_fee"],
      drivy: (list_of_commissions["drivy_fee"] + deductible_reduction_amount).to_i
    }

    list_of_actors_involved_in_payment_process = %w(driver owner insurance assistance drivy)
    list_of_actors_involved_in_payment_process.each do |actor|
      hash_of_results = {}
      list_of_info_to_produce = %w(who type amount)

      hash_of_results[list_of_info_to_produce[0]] = actor
      if actor == "driver"
        hash_of_results[list_of_info_to_produce[1]] = "debit"
      else
        hash_of_results[list_of_info_to_produce[1]] = "credit"
      end
      hash_of_results[list_of_info_to_produce[2]] = list_of_amounts[actor.to_sym]
      who_owe_what_results << hash_of_results
    end
    return who_owe_what_results
  end

  def compute_who_owe_what_after_rental_modifications(car)
    self.compute_rental_price(car.price_per_km, car.price_per_day)
    old_commission = Commission.new.computation_of_commission_amount_and_fees(self.price, self.length)
    self.deductible_reduction_amount = self.compute_deductible_reduction_amount(self.length, self.is_deductible_reduction)
    self.compute_who_owe_what(old_commission, self.deductible_reduction_amount)
  end

  def compute_change_actions(old_rental, new_rental, car)
    old_actions = old_rental.compute_who_owe_what_after_rental_modifications(car)
    new_actions = new_rental.compute_who_owe_what_after_rental_modifications(car)

    change_actions = []
    new_actions.each do |new_action|
      each_action_result = {}
      old_action = old_actions.select { |k| k['who'] == new_action['who'] }.first
      rental_modification_amount = new_action['amount'] - old_action['amount']
      each_action_result['who'] = new_action['who']
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
end
