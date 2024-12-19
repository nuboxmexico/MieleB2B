class CreatePromotionalCodes < ActiveRecord::Migration[5.2]
  def change
    create_table :promotional_codes do |t|
      t.string :name
      t.string :code
      t.text :description
      t.integer :use_limit
      t.date :start_date
      t.date :end_date
      t.integer :percent

      t.timestamps
    end
  end
end
