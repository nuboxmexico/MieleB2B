class AddNewFieldsToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :built_in, :boolean, default: false
    add_column :products, :instalation, :boolean, default: false
    add_column :products, :outlet, :boolean, default: false
  end
end
