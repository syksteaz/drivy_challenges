require 'json'
require 'date'

  def price_of_rental
    raw_input = JSON.parse(IO.read('data.json'))
    results = Array.new
    raw_input["rentals"].each do |rental|
      res = Hash.new
      rental_car_id = rental["car_id"]
      rental_distance = rental["distance"]
      rental_start_date = Date.parse(rental["start_date"]).mjd
      rental_end_date = Date.parse(rental["end_date"]).mjd
      car_array = raw_input["cars"].select { |car| car["id"] == rental_car_id }
      price_per_km = car_array.first["price_per_km"]
      rental_nb_of_days = rental_end_date - rental_start_date + 1
      total_price_distance_component = rental_distance * price_per_km
      rental_total_price =
      ( computation_of_price_time_component(car_array, rental_nb_of_days) +
        total_price_distance_component).to_i
      res["id"] = rental["id"]
      res["price"] = rental_total_price
      res["commission"] = computation_of_commission_and_fees(rental_total_price, rental_nb_of_days)
      results << res
    end
    final_result = Hash.new
    final_result["rentals"] = results
    File.open('output2.json', 'w') do |file|
      # before submiting file to Drivy, replace output2.json with output.json
      file.write(JSON.generate(final_result))
    end
    puts JSON.pretty_generate(final_result)
  end

  def computation_of_commission_and_fees(rental_total_price, rental_nb_of_days)
    commission_and_fee_hash = Hash.new
    commission_rate = 0.3
    commission = rental_total_price * commission_rate
    insurance_fee = (commission * 0.5).to_i
    roadside_assistance_fee = rental_nb_of_days * 100
    drivy_fee = (commission - insurance_fee - roadside_assistance_fee).to_i
    commission_and_fee_hash["insurance_fee"] = insurance_fee
    commission_and_fee_hash["assistance_fee"] = roadside_assistance_fee
    commission_and_fee_hash["drivy_fee"] = drivy_fee
    return commission_and_fee_hash
  end

  def computation_of_price_time_component(car_array, rental_nb_of_days)
    price_per_day = car_array.first["price_per_day"]
    price_per_day_discounted_by_10 = price_per_day * 0.9
    price_per_day_discounted_by_30 = price_per_day * 0.7
    price_per_day_discounted_by_50 = price_per_day * 0.5

    if rental_nb_of_days == 1
      nb_day_at_full_price = 1
      total_price_time_component = nb_day_at_full_price * price_per_day
    elsif rental_nb_of_days.between?(1,4)
      nb_day_at_full_price = 1
      nb_day_at_price_discounted_by_10 = rental_nb_of_days - 1
      total_price_time_component = nb_day_at_full_price * price_per_day +
      nb_day_at_price_discounted_by_10 * price_per_day_discounted_by_10
    elsif rental_nb_of_days.between?(4,10)
      nb_day_at_full_price = 1
      nb_day_at_price_discounted_by_10 = 3
      nb_day_at_price_discounted_by_30 = rental_nb_of_days -
      (nb_day_at_full_price + nb_day_at_price_discounted_by_10)
      total_price_time_component = nb_day_at_full_price * price_per_day +
      nb_day_at_price_discounted_by_10 * price_per_day_discounted_by_10 +
      nb_day_at_price_discounted_by_30 * price_per_day_discounted_by_30
    elsif rental_nb_of_days > 11
      nb_day_at_full_price = 1
      nb_day_at_price_discounted_by_10 = 3
      nb_day_at_price_discounted_by_30 = 6
      nb_day_at_price_discounted_by_50 = rental_nb_of_days -
      (nb_day_at_full_price + nb_day_at_price_discounted_by_10 +
        nb_day_at_price_discounted_by_30)
      total_price_time_component = nb_day_at_full_price * price_per_day +
      nb_day_at_price_discounted_by_10 * price_per_day_discounted_by_10 +
      nb_day_at_price_discounted_by_30 * price_per_day_discounted_by_30 +
      nb_day_at_price_discounted_by_50 * price_per_day_discounted_by_50
    end
  end

  price_of_rental
