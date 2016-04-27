require 'pry'
require 'json'
require 'date'
require_relative 'car'
require_relative 'rental'
require_relative 'commission'

def produce_output_data_from_input_data # to be renamed in intialize_data_and_structure_output_data ?
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
    # car data do not change, it's a kind of constant
    car = Car.new(raw_input['cars'].select { |c| c['id'] == new_rental.car_id }) # we can use it for both old and new rental
    # from here we cant to compute metrics on old data

    old_rental.compute_who_owe_what_after_rental_modifications(car, @old_actions)
    new_rental.compute_who_owe_what_after_rental_modifications(car, @new_actions)

    # def compute_rental_modifications_who_owe_what(car, @variable_name)
    #   old_rental.compute_rental_price(car.price_per_km, car.price_per_day)
    #   old_commission = Commission.new.computation_of_commission_amount_and_fees(old_rental.price, old_rental.length)
    #   old_rental.deductible_reduction_amount = old_rental.compute_deductible_reduction_amount(old_rental.length, old_rental.is_deductible_reduction)
    #   # from here we cant to compute metrics on new data
    #   new_rental.compute_rental_price(car.price_per_km, car.price_per_day)
    #   new_commission = Commission.new.computation_of_commission_amount_and_fees(new_rental.price, new_rental.length)
    #   new_rental.deductible_reduction_amount = new_rental.compute_deductible_reduction_amount(new_rental.length, new_rental.is_deductible_reduction)
    #   # from here we cant to compute difference between new and old data
    #   @old_actions = old_rental.compute_who_owe_what(old_commission, old_rental.deductible_reduction_amount)
    #   @new_actions = new_rental.compute_who_owe_what(new_commission, new_rental.deductible_reduction_amount)
    # end

    def compute_rental_modifications_who_owe_what(car, variable_name)
      self.compute_rental_price(car.price_per_km, car.price_per_day)
      old_commission = Commission.new.computation_of_commission_amount_and_fees(self.price, self.length)
      self.deductible_reduction_amount = self.compute_deductible_reduction_amount(self.length, self.is_deductible_reduction)
      variable_name = self.compute_who_owe_what(old_commission, self.deductible_reduction_amount)
    end

    ################"" here is a method to compute the changes in amount and the type of payment (debit / credit)
    change_actions = []
    @new_actions.each do |new_action|
      each_action_result = {}
      # we select the hash of data in old_actions corresponding to the 'who' of the current hash
      old_action = @old_actions.select { |k| k['who'] == new_action['who'] }.first
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
    # here the following part is about creating the hash of results
    results << prepare_intermediary_result_hash_of_data(rental_data['id'], new_rental.id, change_actions)
  end
  write_to_json_file(prepare_hash_of_data_to_be_transfered_to_json(results))
  puts JSON.pretty_generate(prepare_hash_of_data_to_be_transfered_to_json(results))
end


private

def prepare_intermediary_result_hash_of_data(rental_modification_id, rental_id, actions) # Change arguments to give a hash, easier
  res = {}
  res['id'] = rental_modification_id
  res['rental_id'] = rental_id
  res['actions'] = actions
  return res
end

# delete that method and put it in 'write_to_json_file' before submitting to drivy
# it's useful now only for the JSON.pretty_generate
def prepare_hash_of_data_to_be_transfered_to_json(results)
  final_result = {}
  final_result['rental_modifications'] = results
  return final_result
end

def write_to_json_file(final_result)
  File.open('output2.json', 'w') do |file|
    # before submiting file to Drivy, replace output2.json with output.json
    file.write(JSON.generate(final_result))
  end
end

produce_output_data_from_input_data


###################### BACK UP BEFORE DOING SHIT... ############################################################
########################################################################################################################
# def produce_output_data_from_input_data
#   raw_input = JSON.parse(IO.read('data.json'))
#   results = []

#   raw_input['rental_modifications'].each do |rental_data|
#     old_rental_data = raw_input["rentals"].find { |h| h["id"] == rental_data["rental_id"] }
#     old_rental = Rental.new(old_rental_data)
#     new_rental_data = old_rental_data.clone
#     old_rental_data.keys.each do |key|
#       new_rental_data[key] = rental_data[key] if rental_data[key] != nil
#     end
#     new_rental = Rental.new(new_rental_data)
#     # car data do not change, it's a kind of constant
#     car = Car.new(raw_input['cars'].select { |c| c['id'] == new_rental.car_id }) # we can use it for both old and new rental
#     # from here we cant to compute metrics on old data
#     old_rental.compute_rental_price(car.price_per_km, car.price_per_day)
#     old_commission = Commission.new.computation_of_commission_amount_and_fees(old_rental.price, old_rental.length)
#     old_rental.deductible_reduction_amount = old_rental.compute_deductible_reduction_amount(old_rental.length, old_rental.is_deductible_reduction)
#     # from here we cant to compute metrics on new data
#     new_rental.compute_rental_price(car.price_per_km, car.price_per_day)
#     new_commission = Commission.new.computation_of_commission_amount_and_fees(new_rental.price, new_rental.length)
#     new_rental.deductible_reduction_amount = new_rental.compute_deductible_reduction_amount(new_rental.length, new_rental.is_deductible_reduction)
#     # from here we cant to compute difference between new and old data
#     old_actions = old_rental.compute_who_owe_what(old_commission, old_rental.deductible_reduction_amount)
#     new_actions = new_rental.compute_who_owe_what(new_commission, new_rental.deductible_reduction_amount)


#     ################"" here is a method to compute the changes in amount and the type of payment (debit / credit)
#     change_actions = []
#     new_actions.each do |new_action|
#       each_action_result = {}
#       # we select the hash of data in old_actions corresponding to the 'who' of the current hash
#       old_action = old_actions.select { |k| k['who'] == new_action['who'] }.first
#       rental_modification_amount = new_action['amount'] - old_action['amount']
#       each_action_result['who'] = new_action['who']
#       if rental_modification_amount < 0.0
#         each_action_result['who'] != 'driver' ? each_action_result['type'] = 'debit' : each_action_result['type'] = 'credit'
#       elsif rental_modification_amount > 0.0
#         each_action_result['who'] != 'driver' ? each_action_result['type'] = 'credit' : each_action_result['type'] = 'debit'
#       end
#       each_action_result['amount'] = rental_modification_amount.abs
#       change_actions << each_action_result
#     end
#     # here the following part is about creating the hash of results
#     results << prepare_intermediary_result_hash_of_data(rental_data['id'], new_rental.id, change_actions)
#   end
#   write_to_json_file(prepare_hash_of_data_to_be_transfered_to_json(results))
#   puts JSON.pretty_generate(prepare_hash_of_data_to_be_transfered_to_json(results))
# end
########################################################################################################################
########################################################################################################################
