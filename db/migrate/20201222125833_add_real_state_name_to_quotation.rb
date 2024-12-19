class AddRealStateNameToQuotation < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :real_state_name, :string
  end
end
