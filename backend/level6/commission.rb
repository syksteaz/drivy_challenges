require 'pry'

class Commission
  # the Commission class aims at computing the commission amount and the splits
  attr_accessor :rate, :amount, :insurance_fee_rate, :insurance_fee_amount, :roadside_assistance_fee, :drivy_fee

  def initialize
    @rate = 0.3
    @insurance_fee_rate = 0.5
  end

  def computation_of_commission_amount_and_fees(rental_total_price, rental_nb_of_days)
    self.amount = rental_total_price * rate
    self.insurance_fee_amount = (amount * insurance_fee_rate).to_i
    self.roadside_assistance_fee = rental_nb_of_days * 100
    self.drivy_fee = (self.amount - self.insurance_fee_amount - self.roadside_assistance_fee).to_i
    prepare_commission_hash_of_data
  end

  def prepare_commission_hash_of_data
    commission_and_fee_hash = {}
    commission_and_fee_hash["insurance_fee"] = self.insurance_fee_amount
    commission_and_fee_hash["assistance_fee"] = self.roadside_assistance_fee
    commission_and_fee_hash["drivy_fee"] = self.drivy_fee
    return commission_and_fee_hash
  end
end
