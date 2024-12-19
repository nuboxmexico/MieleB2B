class AddActivationConfirmToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :activation_confirm, :boolean, default: true
  end
end
