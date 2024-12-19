class AddSaleChannelToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_reference :quotations, :sale_channel, foreign_key: true
  end
end
