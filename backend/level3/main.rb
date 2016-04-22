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
      car_array = raw_input["cars"].select { |car| car["id"] == rental.car_id }
      car = Car.new(car_array)
      rental.price = rental.compute_rental_price(car.price_per_km, car.price_per_day)
      commission = Commission.new.computation_of_commission_amount_and_fees(rental.price, rental.length)
      results << prepare_intermediary_result_hash_of_data(rental.id, rental.price, commission)
    end
    final_result = Hash.new
    final_result["rentals"] = results
    write_to_json_file(final_result)
    puts JSON.pretty_generate(final_result)
  end

  private

  def prepare_intermediary_result_hash_of_data(rental_id, rental_price, commission)
    res = Hash.new
    res["id"] = rental_id
    res["price"] = rental_price
    res["commission"] = commission
    return res
  end

  def write_to_json_file(final_result)
    File.open('output2.json', 'w') do |file|
      # before submiting file to Drivy, replace output2.json with output.json
      file.write(JSON.generate(final_result))
    end
    puts JSON.pretty_generate(final_result)
  end

  produce_output_data_from_input_data
