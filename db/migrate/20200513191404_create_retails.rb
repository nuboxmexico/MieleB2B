class CreateRetails < ActiveRecord::Migration[5.2]
  def change
    create_table :retails do |t|
      t.string :name

      t.timestamps
    end
  end
end
