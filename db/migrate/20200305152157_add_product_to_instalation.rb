class AddProductToInstalation < ActiveRecord::Migration[5.2]
  def change
    add_reference :instalations, :product, foreign_key: true
  end
end
