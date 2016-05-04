require 'json'
require 'date'
require 'pry'
require_relative 'car'
require_relative 'rental'
require_relative 'commission'

  def produce_output_data_from_input_data
    raw_input = JSON.parse(IO.read('data.json'))
    results = []
    raw_input['rentals'].each do |rental_data|
      car = Car.new(raw_input['cars'].select { |car| car['id'] == rental_data['car_id'] })
      rental = Rental.new(rental_data, car)
      commission = Commission.new(rental)
      results <<  { 'id'         => rental.id,
                    'price'      => rental.total_price,
                    'options'    => { 'deductible_reduction'  => rental.deductible_reduction_amount },
                    'commission' => { 'insurance_fee'         => commission.insurance_fee,
                                      'assistance_fee'        => commission.roadside_assistance_fee,
                                      'drivy_fee'             => commission.drivy_fee }
                  }
    end
    write_to_json_file(results)
  end

  private

  def write_to_json_file(results)
    final_result = {}
    final_result['rentals'] = results
    File.open('output2.json', 'w') do |file|
      # !! before submiting file to Drivy, replace output2.json with output.json
      file.write(JSON.pretty_generate(final_result))
    end
  end

  produce_output_data_from_input_data
