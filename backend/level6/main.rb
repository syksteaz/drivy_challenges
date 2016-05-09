require 'pry'
require 'json'
require 'date'
require_relative 'car'
require_relative 'rental'
require_relative 'commission'

def structure_input_data_and_iterate_over_it
  raw_input = JSON.parse(IO.read('data.json'))
  results = []
  raw_input['rental_modifications'].each do |rental_data_modifications|
    old_rental_data = raw_input['rentals'].select { |r| r['id'] == rental_data_modifications['rental_id'] }.first
    car = Car.new(raw_input['cars'].select { |c| c['id'] == old_rental_data['car_id'] })
    old_rental = Rental.new(old_rental_data, car)
    new_rental = Rental.new(Rental.build_new_rental_data(old_rental_data, rental_data_modifications), car)
    results << {  'id' => rental_data_modifications['id'],
                  'rental_id' => rental_data_modifications['rental_id'],
                  'actions' => new_rental.compute_change_actions(old_rental, new_rental, car)
               }
  end
  write_to_json_file(results)
end

private

def write_to_json_file(results)   # before submiting file to Drivy, replace output2.json with output.json
  File.open('output2.json', 'w') do |file|
    file.write(JSON.pretty_generate({ 'rental_modifications' => results }))
  end
end

structure_input_data_and_iterate_over_it
