class CreateMandatoryProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :mandatory_products do |t|

      t.timestamps
    end
  end
end
