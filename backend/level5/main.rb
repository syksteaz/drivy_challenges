require 'json'
require 'date'
require 'pry'
require_relative 'car'
require_relative 'rental'
require_relative 'commission'
require_relative 'payment_action'

  def produce_output_data_from_input_data
    raw_input = JSON.parse(IO.read('data.json'))
    results = []
    raw_input['rentals'].each do |rental_data|
      car = Car.new(raw_input['cars'].select { |car| car['id'] == rental_data['car_id'] })
      rental = Rental.new(rental_data, car)
      commission = Commission.new(rental)
      results <<  { 'id'      => rental.id,
                    'actions' => compute_and_structure_payment_actions_data(rental, commission)
                  }
    end
    write_to_json_file(results)
  end

  private

  def compute_and_structure_payment_actions_data(rental, commission)
    res = []
    %w(driver owner insurance assistance drivy).each do |actor|
      payment_action = PaymentAction.new(actor, rental, commission)
      res << {  'who' => payment_action.who,
                'type' => payment_action.type,
                'amount' => payment_action.amount}
    end
    return res
  end


  def write_to_json_file(results)
    final_result = {}
    final_result['rentals'] = results
    File.open('output2.json', 'w') do |file|
      # !! before submiting file to Drivy, replace output2.json with output.json
      file.write(JSON.pretty_generate(final_result))
    end
  end

  produce_output_data_from_input_data
