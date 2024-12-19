class CreateInstalations < ActiveRecord::Migration[5.2]
  def change
    create_table :instalations do |t|
      t.string :name

      t.timestamps
    end
  end
end
