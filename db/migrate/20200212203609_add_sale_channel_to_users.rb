class AddSaleChannelToUsers < ActiveRecord::Migration[5.2]
  def change
    add_reference :users, :sale_channel, foreign_key: true
  end
end
