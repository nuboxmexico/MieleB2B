class CreateDetailQuotationProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :detail_quotation_products do |t|
      t.string :name
      t.string :state
      t.string :tnr
      t.string :serial_id
      t.string :core_id
      t.references :quotation_product, foreign_key: true
      t.timestamps
    end
  end
end
