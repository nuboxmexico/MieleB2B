class RemoveTableServices < ActiveRecord::Migration[5.2]
  def change
  	drop_table :quotation_services
  	drop_table :cart_services
  	drop_table :services
  end
end
