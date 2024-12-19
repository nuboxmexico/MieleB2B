class CreateJoinTableSaleChannelsProducts < ActiveRecord::Migration[5.2]
  def change
    create_join_table :sale_channels, :products do |t|
      # t.index [:sale_channel_id, :product_id]
      # t.index [:product_id, :sale_channel_id]
    end
  end
end
