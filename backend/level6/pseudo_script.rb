# // we iterate on each rentals
# // check if for a given rental there is deductible_reduction
# // if yes we create nother rental_object
#   // both rentals and rental_modifications hash have the same key
#   // so if it's present in the rental_modifications we take the value there
#   // or we keep the first_car value if the key is not in the hash (nil value)
# // if yes we compute a before_price and an after_price
# //
# // We could create a method to check if the rental_id is in the rental_modifications hash
# // an consequently create a another rental_object
# // an another value to compute the difference between the 2
# // without touching too much def produce_output_data_from_input_data


# // we are gonna iterate on rental_modifications first so that we do not build
# // rental_object which are useless because there are no changes on it

# // building the rental we must start with the old one on which we have all elements

raw_input = JSON.parse(
  '
  {
  "cars": [
    { "id": 1, "price_per_day": 2000, "price_per_km": 10 }
  ],
  "rentals": [
    { "id": 1, "car_id": 1, "start_date": "2015-12-8", "end_date": "2015-12-8", "distance": 100, "deductible_reduction": true },
    { "id": 2, "car_id": 1, "start_date": "2015-03-31", "end_date": "2015-04-01", "distance": 300, "deductible_reduction": false },
    { "id": 3, "car_id": 1, "start_date": "2015-07-3", "end_date": "2015-07-14", "distance": 1000, "deductible_reduction": true }
  ],
  "rental_modifications": [
    { "id": 1, "rental_id": 1, "end_date": "2015-12-10", "distance": 150 },
    { "id": 2, "rental_id": 3, "start_date": "2015-07-4" }
  ]
}')
