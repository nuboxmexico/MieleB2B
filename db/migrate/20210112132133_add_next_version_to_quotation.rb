class AddNextVersionToQuotation < ActiveRecord::Migration[5.2]
  def change
    add_reference :quotations, :quotation, foreign_key: true
  end
end
