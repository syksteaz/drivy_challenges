require 'json'
require 'date'
require 'pry'

require_relative 'car'
require_relative 'rental'

def price_of_rental
  raw_input = JSON.parse(IO.read('data.json'))
  results = []
  raw_input['rentals'].each do |rental_data|
    car = Car.new(raw_input['cars'].select { |car| car['id'] == rental_data['car_id'] }.first)
    rental = Rental.new(rental_data, car)
    results << {  'id'    => rental.id,
                  'price' => rental.total_price }
  end
  prepare_json(results)
end

def prepare_json(results)
  final_result = {}
  final_result['rentals'] = results
  File.open('output2.json', 'w') do |file|
    # before submiting file to Drivy, replace output2.json with output.json
    file.write(JSON.pretty_generate(final_result))
  end
  puts JSON.pretty_generate(final_result)
end

price_of_rental
