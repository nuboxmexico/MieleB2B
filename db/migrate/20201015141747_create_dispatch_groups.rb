class CreateDispatchGroups < ActiveRecord::Migration[5.2]
  def change
    create_table :dispatch_groups do |t|
      t.string :dispatch_order
      t.integer :reception_type
      t.text :observations
      t.references :quotation, foreign_key: true

      t.timestamps
    end
  end
end
