# the main.rb file aims at being ran with ruby main.rb to produce output.json
require 'pry'
require 'json'
require 'date'
require_relative 'car'
require_relative 'rental'
require_relative 'commission'

def structure_input_data_and_iterate_over_it # to be renamed in intialize_data_and_structure_output_data ?
  raw_input = JSON.parse(IO.read('data.json'))
  results = []
  raw_input['rental_modifications'].each do |rental_data|
    create_new_and_old_rental(raw_input, rental_data)
    car = Car.new(raw_input['cars'].select { |c| c['id'] == @new_rental.car_id })
    change_actions = @new_rental.compute_change_actions(@old_rental, @new_rental, car)
    results << prepare_intermediary_result_hash_of_data(rental_data['id'], @new_rental.id, change_actions)
  end
  write_to_json_file(prepare_hash_of_data_to_be_transfered_to_json(results))
  puts JSON.pretty_generate(prepare_hash_of_data_to_be_transfered_to_json(results)) # to be deleted before submitting to drivy just useful for debug output.json
end

private

def create_new_and_old_rental(raw_input, rental_data) # this could be transfered in Rental Class, but making it an instance method is weird 'cause the rental instance on which it is called is not used.
    old_rental_data = raw_input["rentals"].find { |h| h["id"] == rental_data["rental_id"] }
    @old_rental = Rental.new(old_rental_data)
    new_rental_data = old_rental_data.clone
    old_rental_data.keys.each do |key|
      new_rental_data[key] = rental_data[key] if rental_data[key] != nil
    end
    @new_rental = Rental.new(new_rental_data)
end

def prepare_intermediary_result_hash_of_data(rental_modification_id, rental_id, actions) # Change arguments to give a hash, easier
  res = {}
  res['id'] = rental_modification_id
  res['rental_id'] = rental_id
  res['actions'] = actions
  return res
end

# delete that method and put it in 'write_to_json_file' before submitting to drivy, it's useful now only for the JSON.pretty_generate
def prepare_hash_of_data_to_be_transfered_to_json(results)
  final_result = {}
  final_result['rental_modifications'] = results
  return final_result
end

def write_to_json_file(final_result)
  # before submiting file to Drivy, replace output2.json with output.json
  File.open('output2.json', 'w') do |file|
    file.write(JSON.generate(final_result))
  end
end

structure_input_data_and_iterate_over_it
