class RemoveChannelToProducts < ActiveRecord::Migration[5.2]
  def change
  	remove_column :products, :channel
  end
end
