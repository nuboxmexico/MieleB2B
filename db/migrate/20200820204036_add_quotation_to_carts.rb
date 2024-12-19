class AddQuotationToCarts < ActiveRecord::Migration[5.2]
  def change
    add_reference :carts, :quotation, foreign_key: true
  end
end
