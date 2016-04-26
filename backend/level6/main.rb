require 'pry'
require 'json'
require 'date'
require_relative 'car'
require_relative 'rental'
require_relative 'commission'

def produce_output_data_from_input_data
  raw_input = JSON.parse(IO.read('data.json'))
  results = []

  raw_input['rental_modifications'].each do |rental_data|
    old_rental_data = raw_input["rentals"].find { |h| h["id"] == rental_data["rental_id"] }
    old_rental = Rental.new(old_rental_data)

    new_rental_data = old_rental_data.clone
    old_rental_data.keys.each do |key|
      new_rental_data[key] = rental_data[key] if rental_data[key] != nil
    end
    new_rental = Rental.new(new_rental_data)

    car = Car.new(raw_input['cars'].select { |c| c['id'] == rental.car_id })
    rental = Rental.new(rental_data)
    rental.compute_rental_price(car.price_per_km, car.price_per_day)
    commission = Commission.new.computation_of_commission_amount_and_fees(rental.price, rental.length)
    rental.deductible_reduction_amount = rental.compute_deductible_reduction_amount(rental.length, rental.is_deductible_reduction)




    actions = rental.compute_who_owe_what(commission, rental.deductible_reduction_amount)
    results << prepare_intermediary_result_hash_of_data(rental.id, actions)
  end
  write_to_json_file(prepare_hash_of_data_to_be_transfered_to_json(results))
  puts JSON.pretty_generate(prepare_hash_of_data_to_be_transfered_to_json(results))
end

private

def prepare_intermediary_result_hash_of_data(rental_id, actions)
  res = {}
  res['id'] = rental_id
  res['actions'] = actions
  return res
end

# delete that method and put it in 'write_to_json_file' before submitting to drivy
# it's useful now for the pretty_generate
def prepare_hash_of_data_to_be_transfered_to_json(results)
  final_result = {}
  final_result['rentals'] = results
  return final_result
end

def write_to_json_file(final_result)
  File.open('output2.json', 'w') do |file|
    # before submiting file to Drivy, replace output2.json with output.json
    file.write(JSON.generate(final_result))
  end
end

produce_output_data_from_input_data
