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
