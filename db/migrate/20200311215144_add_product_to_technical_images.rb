class AddProductToTechnicalImages < ActiveRecord::Migration[5.2]
  def change
    add_reference :technical_images, :product, foreign_key: true
  end
end
