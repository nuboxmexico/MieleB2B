class AddCodeToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :code, :string
  end
end
