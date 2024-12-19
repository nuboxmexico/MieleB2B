class AddDispatchGroupToDetailQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    add_reference :detail_quotation_products, :dispatch_group, foreign_key: true
  end
end
