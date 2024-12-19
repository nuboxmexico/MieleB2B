class CreateUnitRealStates < ActiveRecord::Migration[5.2]
  def change
    create_table :unit_real_states do |t|
      t.references :quotation, foreign_key: true
      t.string :name
      t.integer :quantity
      t.integer :products_quantity
      t.timestamps
    end
  end
end