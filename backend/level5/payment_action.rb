class PaymentAction
  attr_accessor :who, :type, :amount

  AMOUNT_PERCEIVED_BY_OWNER = 0.7

  def initialize(actor, rental, commission)
    @who  = actor
    @type = @who == 'driver' ? 'debit' : 'credit'
    @amount = compute_amount_of_payment_action(@who, rental, commission)
  end

  def compute_amount_of_payment_action(actor, rental, commission)
    if actor == 'driver'
      rental.total_price + rental.deductible_reduction_amount
    elsif actor == 'owner'
      (rental.total_price * AMOUNT_PERCEIVED_BY_OWNER).to_i
    elsif actor == 'insurance'
      commission.insurance_fee
    elsif actor == 'assistance'
      commission.roadside_assistance_fee
    elsif actor == 'drivy'
      (commission.drivy_fee + rental.deductible_reduction_amount).to_i
    end
  end
end
