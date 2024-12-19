class AddPromotionalCodeToQuotation < ActiveRecord::Migration[5.2]
  def change
    add_reference :quotations, :promotional_code, foreign_key: true
  end
end
