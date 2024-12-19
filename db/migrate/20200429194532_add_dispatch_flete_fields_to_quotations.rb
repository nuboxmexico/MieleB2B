class AddDispatchFleteFieldsToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :dispatch_order, :string
  end
end
