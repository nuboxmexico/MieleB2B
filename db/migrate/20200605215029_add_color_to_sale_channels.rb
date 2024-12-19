class AddColorToSaleChannels < ActiveRecord::Migration[5.2]
  def change
    add_column :sale_channels, :color, :string
  end
end
