class CreateTechnicalImages < ActiveRecord::Migration[5.2]
  def change
    create_table :technical_images do |t|

      t.timestamps
    end
  end
end
