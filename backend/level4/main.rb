require 'json'
require 'date'
require_relative 'car'
require_relative 'rental'
require_relative 'commission'

  def produce_output_data_from_input_data
    raw_input = JSON.parse(IO.read('data.json'))
    results = Array.new
    raw_input["rentals"].each do |rental_data|
      rental = Rental.new(rental_data)
      car = Car.new(raw_input["cars"].select { |car| car["id"] == rental.car_id })
      rental.price = rental.compute_rental_price(car.price_per_km, car.price_per_day)
      commission = Commission.new.computation_of_commission_amount_and_fees(rental.price, rental.length)
      rental.deductible_reduction_amount = rental.compute_deductible_reduction_amount(rental.length, rental.is_deductible_reduction)
      results << prepare_intermediary_result_hash_of_data(rental.id, rental.price, commission, rental.deductible_reduction_amount)
    end
    write_to_json_file(prepare_hash_of_date_to_be_transfered_to_json(results))
    puts JSON.pretty_generate(prepare_hash_of_date_to_be_transfered_to_json(results))
  end

  private

  def prepare_intermediary_result_hash_of_data(rental_id, rental_price, commission, deductible_reduction_amount)
    res = Hash.new
    commission_res = Hash.new
    commission_res["deductible_reduction"] = deductible_reduction_amount
    res["id"] = rental_id
    res["price"] = rental_price
    res["options"] = commission_res
    res["commission"] = commission
    return res
  end

  def prepare_hash_of_date_to_be_transfered_to_json(results)
    final_result = Hash.new
    final_result["rentals"] = results
  end

  def write_to_json_file(final_result)
    File.open('output2.json', 'w') do |file|
      # before submiting file to Drivy, replace output2.json with output.json
      file.write(JSON.generate(final_result))
    end
  end

  produce_output_data_from_input_data


# deductible reduction has impact on :
#   rental Class
#   total price
#   drivy fee
