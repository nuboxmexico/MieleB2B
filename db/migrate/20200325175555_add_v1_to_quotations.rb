class AddV1ToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :v1, :string
  end
end
