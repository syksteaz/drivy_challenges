class Rental
  attr_accessor :id, :car_id, :distance, :start_date, :end_date, :nb_of_days

  def initialize(rental = {})
    @id = rental['id']
    @car_id = rental['car_id']
    @distance = rental['distance']
    @start_date = Date.parse(rental['start_date']).mjd
    @end_date = Date.parse(rental['end_date']).mjd
    @nb_of_days = end_date - start_date + 1
  end

  # def computation_of_distance_component(car)
  #   self.price_distance_component = distance * car.price_per_km
  # end

  def computation_of_price_time_component(car)
    self.define_price_variables(car)
    self.compute_nb_of_days_at_each_price
    self.discount_component_of_price

    @full_price_component.to_i +
      @price_discount_by_10_component.to_i +
      @price_discount_by_30_component.to_i +
      @price_discount_by_50_component.to_i
  end

  def define_price_variables(car)
    @price_per_day = car.price_per_day
    @price_per_day_discounted_by_10 = @price_per_day * 0.9 # pas indispensable
    @price_per_day_discounted_by_30 = @price_per_day * 0.7
    @price_per_day_discounted_by_50 = @price_per_day * 0.5
    @discount_by_10_min_threshold = 1 # ici ça pourrait être des constantes plutôt que des variables d'instance
    @discount_by_10_max_threshold = 4
    @discount_by_30_min_threshold = 4 # ne pas répéter deux fois les seuils identiques
    @discount_by_30_max_threshold = 10
    @discount_by_50_min_threshold = 10 #
  end

  def compute_nb_of_days_at_each_price # ici on pourrait checker en entrée si nb_of_days < min threshold et mettre 0
    # pour réllement calculer le nombre de jours
    # ici on pourrait créer un array d'array avec le résultat des calcul plutot que des pseudos variables d'instance
    @days_at_full_price = self.nb_of_days >= 1 ? 1 : self.nb_of_days
    @days_at_10_discount = self.nb_of_days > @discount_by_10_max_threshold ? (@discount_by_10_max_threshold -
      @discount_by_10_min_threshold) : (self.nb_of_days - @discount_by_10_min_threshold)
    @days_at_30_discount = self.nb_of_days > @discount_by_30_max_threshold ? (@discount_by_30_max_threshold -
      @discount_by_30_min_threshold) : (self.nb_of_days - @discount_by_30_min_threshold)
    @days_at_50_discount = self.nb_of_days > @discount_by_50_min_threshold ? (self.nb_of_days -
      @discount_by_50_min_threshold) : 0
  end

  def discount_component_of_price
    @full_price_component = (@days_at_full_price > 0 ? @days_at_full_price : 0) * @price_per_day
    @price_discount_by_10_component = (@days_at_10_discount > 0 ? @days_at_10_discount : 0) * @price_per_day_discounted_by_10
    @price_discount_by_30_component = (@days_at_30_discount > 0 ? @days_at_30_discount : 0) * @price_per_day_discounted_by_30
    @price_discount_by_50_component = (@days_at_50_discount > 0 ? @days_at_50_discount : 0) * @price_per_day_discounted_by_50
  end

  def computation_of_total_price(car) # attention ici c'est faux (2 fois la même chose, et distance component n'est plus utilisé)
    (self.computation_of_price_time_component(car) +
    self.computation_of_price_time_component(car)).to_i
  end

end
