class CreateCartServices < ActiveRecord::Migration[5.2]
  def change
    create_table :cart_services do |t|
      t.references :cart, foreign_key: true
      t.references :service, foreign_key: true

      t.timestamps
    end
  end
end
