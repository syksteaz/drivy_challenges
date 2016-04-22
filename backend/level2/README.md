# Level 2

To be as competitive as possible, we decide to have a decreasing pricing for longer rentals.

New rules:
- price per day decreases by 10% after 1 day => note EWI : starts @ day 2
- price per day decreases by 30% after 4 days => note EWI : starts @ day 5
- price per day decreases by 50% after 10 days => note EWI : starts @ day 11

Adapt the rental price computation to take these new rules into account.


// EWI
# we have thresholds : 1, 4, 10
# we can compute the difference between the rental_nb_of_days and these thresholds and then
# apply the discount

if total_days == 1
  day at full price = 1
  price = day at full price
elsif total_days > 1 && < 5
  days at full price = 1
  days at 10% discount = total_days - 1
  price = days at full price + days at 10% discount
elsif total days > 4 && < 11
  days at full price = 1
  days at 10% discount = 3
  days at 30% discount = total_days - (days at full price + days at 10% discount)
  price = days at full price + days at 10% + days at 30%
elsif total days > 11
  days at full price = 1
  days at 10% discount = 3
  days at 30% discount = 6
  days at 50% discount = total_days - (days at full price + days at 10% discount + days at 30% discount)
  price = days at full price + days at 10% + days at 30% + days at 50 %
end
