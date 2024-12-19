class AddDispatchFieldsToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :dispatch_guide, :string
    add_column :quotations, :dispatch_type, :string
  end
end
