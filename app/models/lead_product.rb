class LeadProduct < ApplicationRecord
  belongs_to :lead

  def total_price
    return self.unit_price.to_f * self.quantity.to_i
  end
end
