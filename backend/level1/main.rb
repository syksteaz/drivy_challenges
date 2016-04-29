require 'json'
require 'date'
require 'pry'

require_relative 'car'
require_relative 'rental'

  def price_of_rental # this method is doing way to much things.. parsing json, creating rental object and car object, computing total_price, preparing json ...
    raw_input = JSON.parse(IO.read('data.json'))
    results = Array.new
    raw_input["rentals"].each do |rental_data|
      res = Hash.new
      rental = Rental.new(rental_data)
      car = Car.new(raw_input["cars"].select { |car| car["id"] == rental.car_id }.first)
      res["id"] = rental.id
      res["price"] = rental.total_price(car)
      results << res
    end
    prepare_json(results)
  end

  def prepare_json(results)
    final_result = Hash.new
    final_result["rentals"] = results
    File.open('output2.json', 'w') do |file|
      # before submiting file to Drivy, replace output2.json with output.json
      file.write(JSON.generate(final_result))
    end
    puts JSON.pretty_generate(final_result)
  end

  price_of_rental
