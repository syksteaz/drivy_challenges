class Commission
  attr_accessor :amount, :insurance_fee, :roadside_assistance_fee, :drivy_fee

  COMMISSION_RATE = 0.3
  INSURANCE_FEE = 0.5
  ROADSIDE_ASSISTANCE_FEE = 100

  def initialize(rental)
    @rental_id = rental.id
    @amount = rental.total_price * COMMISSION_RATE
    @insurance_fee = (@amount * INSURANCE_FEE).to_i
    @roadside_assistance_fee = rental.nb_of_days * ROADSIDE_ASSISTANCE_FEE
    @drivy_fee = (@amount - @insurance_fee - @roadside_assistance_fee).to_i
  end
end
