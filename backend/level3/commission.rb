class Commission
  attr_accessor :rate, :amount, :insurance_fee, :roadside_assistance_fee, :drivy_fee

  def initialize(rental)
    @rate = 0.3 #ajouter un rental id
    # @rental_total_price
    @rental = rental
  end

  def computation_of_commission_amount_and_fees(rental_total_price, rental_nb_of_days)
    @amount = rental_total_price * self.rate
    self.insurance_fee = (self.amount * 0.5).to_i
    self.roadside_assistance_fee = rental_nb_of_days * 100
    self.drivy_fee = (self.amount - self.insurance_fee - self.roadside_assistance_fee).to_i
    prepare_commission_hash_of_data(self.insurance_fee, self.roadside_assistance_fee, self.drivy_fee)
  end

  def prepare_commission_hash_of_data(insurance_fee, roadside_assitance_fee, drivy_fee) # transfer ça au niveau du main
    commission_and_fee_hash = Hash.new
    commission_and_fee_hash["insurance_fee"] = self.insurance_fee
    commission_and_fee_hash["assistance_fee"] = self.roadside_assistance_fee
    commission_and_fee_hash["drivy_fee"] = self.drivy_fee
    return commission_and_fee_hash
  end
end
