class CreateSaleChannels < ActiveRecord::Migration[5.2]
  def change
    create_table :sale_channels do |t|
      t.string :name

      t.timestamps
    end
  end
end
