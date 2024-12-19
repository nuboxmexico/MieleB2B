class AddRetailActiveBooleanState < ActiveRecord::Migration[5.2]
  def change
    add_column :retails, :active, :boolean, default: false
  end
end
