class AddDepthToFamilies < ActiveRecord::Migration[5.2]
  def change
    add_column :families, :depth, :integer, default: 0
  end
end
