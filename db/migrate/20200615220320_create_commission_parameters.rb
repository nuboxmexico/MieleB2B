class CreateCommissionParameters < ActiveRecord::Migration[5.2]
  def change
    create_table :commission_parameters do |t|
      t.integer :lower_bound
      t.integer :upper_bound
      t.integer :level_a
      t.integer :level_b
      t.integer :level_c

      t.timestamps
    end
  end
end
