class AddFieldsToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :description, :text
    add_column :products, :channel, :string
    add_column :products, :can_retire, :boolean
  end
end
