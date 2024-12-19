class CreateComparableAttributes < ActiveRecord::Migration[5.2]
  def change
    create_table :comparable_attributes do |t|
      t.string :name

      t.timestamps
    end
  end
end
