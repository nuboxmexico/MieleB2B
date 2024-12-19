class CreateQuotationServices < ActiveRecord::Migration[5.2]
  def change
    create_table :quotation_services do |t|
      t.references :quotation, foreign_key: true
      t.references :service, foreign_key: true
      t.integer :price
      t.string :name

      t.timestamps
    end
  end
end
