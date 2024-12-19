class CreateCodesPerChannels < ActiveRecord::Migration[5.2]
  def change
    create_table :codes_per_channels do |t|
      t.references :promotional_code, foreign_key: true
      t.references :sale_channel, foreign_key: true

      t.timestamps
    end
  end
end
