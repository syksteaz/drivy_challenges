require 'json'
require 'date'

# your code

# 1) import the data
raw_input = JSON.parse(IO.read('data.json'))




# 2) define variable entering the
# computation by their relative
# positioning in the input data
# 3) define a method to compute the price
  # - time component : nb of days * price per day
  # - distance component : nb of km * price per km

  # ! for price_per_day and price_per_kilometers we take cars based on their index but it will be nice
  # to put something stronger in case their is a whole in the data
  # or if they are not sorted

  def price_of_rental
    results = Array.new
    raw_input["rentals"].each do |rental|
      res = Hash.new
      rental_start_date = Date.parse(rental["start_date"]).mjd
      rental_end_date = Date.parse(rental["end_date"]).mjd
      rental_nb_of_days = rental_end_date - rental_start_date + 1
      rental_car_id = rental["car_id"]
      rental_distance = rental["distance"]
      car_array = raw_input["cars"].select { |car| car["id"] == rental_car_id }
      # price_per_day = raw_input["cars"][rental_car_id - 1]["price_per_day"]
      price_per_day = car_array.first["price_per_day"]
      # price_per_km = raw_input["cars"][rental_car_id - 1]["price_per_km"]
      price_per_km = car_array.first["price_per_km"]
      total_price_time_component = rental_nb_of_days * price_per_day
      total_price_distance_component = rental_distance * price_per_km
      rental_total_price = total_price_time_component + total_price_distance_component
      res["id"] = rental["id"]
      res["price"] = rental_total_price
      results << res
    end
    final_result = Hash.new
    final_result["rentals"] = results
    File.open('output2.json', 'w') do |file|
      # before submiting file to Drivy, replace output2.json with output.json
      file.write(JSON.generate(final_result))
    end
    puts JSON.pretty_generate(final_result)
  end
