class AddDispatchValueToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :dispatch_value, :integer, default: 0
  end
end
