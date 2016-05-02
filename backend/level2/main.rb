# rubocop to be seen :
  # Redundant self detected.
  # Assignment Branch Condition size is too high

require 'json'
require 'date'
require 'pry'
require_relative 'rental'
require_relative 'car'

  def structure_data_and_compute_price_of_rental
    raw_input = JSON.parse(IO.read('data.json'))
    results = []
    raw_input['rentals'].each do |rental_data|
      rental = Rental.new(rental_data)
      car = Car.new(raw_input['cars'].select { |car_data| car_data['id'] == rental.car_id }.first)
      results << {  'id' => rental.id,
                    'price' => rental.computation_of_total_price(car) }
    end
    produce_json_file(results)
  end

  def produce_json_file(results)
    File.open('output2.json', 'w') do |file|
      # before submiting file to Drivy, replace output2.json with output.json
      file.write(JSON.generate('rentals' => results))
    end
    puts JSON.pretty_generate('rentals' => results)
  end

structure_data_and_compute_price_of_rental




################### avant refacto : pas d'objets crées #######################
##############################################################################
  # def price_of_rental
  #   raw_input = JSON.parse(IO.read('data.json'))
  #   results = Array.new
  #   raw_input["rentals"].each do |rental|
  #     res = Hash.new
  #     rental_car_id = rental["car_id"]
  #     rental_distance = rental["distance"]
  #     rental_start_date = Date.parse(rental["start_date"]).mjd
  #     rental_end_date = Date.parse(rental["end_date"]).mjd
  #     rental_nb_of_days = rental_end_date - rental_start_date + 1

  #     car_array = raw_input["cars"].select { |car| car["id"] == rental_car_id }
  #     car_price_per_km = car_array.first["price_per_km"]

  #     total_price_distance_component = rental_distance * car_price_per_km
  #     rental_total_price =
  #     ( computation_of_price_time_component(car_array, rental_nb_of_days) +
  #       total_price_distance_component).to_i
  #     res["id"] = rental["id"]
  #     res["price"] = rental_total_price
  #     results << res
  #   end
  #   final_result = Hash.new
  #   final_result["rentals"] = results
  #   File.open('output2.json', 'w') do |file|
  #     # before submiting file to Drivy, replace output2.json with output.json
  #     file.write(JSON.generate(final_result))
  #   end
  #   puts JSON.pretty_generate(final_result)
  # end

  # def computation_of_price_time_component(car_array, rental_nb_of_days)
  #   price_per_day = car_array.first["price_per_day"]
  #   price_per_day_discounted_by_10 = price_per_day * 0.9
  #   price_per_day_discounted_by_30 = price_per_day * 0.7
  #   price_per_day_discounted_by_50 = price_per_day * 0.5

  #   if rental_nb_of_days == 1
  #     nb_day_at_full_price = 1
  #     total_price_time_component = nb_day_at_full_price * price_per_day
  #   elsif rental_nb_of_days.between?(1,4)
  #     nb_day_at_full_price = 1
  #     nb_day_at_price_discounted_by_10 = rental_nb_of_days - 1
  #     total_price_time_component = nb_day_at_full_price * price_per_day +
  #     nb_day_at_price_discounted_by_10 * price_per_day_discounted_by_10
  #   elsif rental_nb_of_days.between?(4,10)
  #     nb_day_at_full_price = 1
  #     nb_day_at_price_discounted_by_10 = 3
  #     nb_day_at_price_discounted_by_30 = rental_nb_of_days -
  #     (nb_day_at_full_price + nb_day_at_price_discounted_by_10)
  #     total_price_time_component = nb_day_at_full_price * price_per_day +
  #     nb_day_at_price_discounted_by_10 * price_per_day_discounted_by_10 +
  #     nb_day_at_price_discounted_by_30 * price_per_day_discounted_by_30
  #   elsif rental_nb_of_days > 11
  #     nb_day_at_full_price = 1
  #     nb_day_at_price_discounted_by_10 = 3
  #     nb_day_at_price_discounted_by_30 = 6
  #     nb_day_at_price_discounted_by_50 = rental_nb_of_days -
  #     (nb_day_at_full_price + nb_day_at_price_discounted_by_10 +
  #       nb_day_at_price_discounted_by_30)
  #     total_price_time_component = nb_day_at_full_price * price_per_day +
  #     nb_day_at_price_discounted_by_10 * price_per_day_discounted_by_10 +
  #     nb_day_at_price_discounted_by_30 * price_per_day_discounted_by_30 +
  #     nb_day_at_price_discounted_by_50 * price_per_day_discounted_by_50
  #   end
  # end

  # price_of_rental
