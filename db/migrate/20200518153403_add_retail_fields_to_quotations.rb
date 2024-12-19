class AddRetailFieldsToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :f12_number, :string
    add_column :quotations, :oc_number, :string
    add_reference :quotations, :retail, foreign_key: true
    add_column :quotations, :agreed_dispatch_date, :date
    add_column :quotations, :dispatch_city, :string
    add_column :quotations, :upc, :string
    add_column :quotations, :receiver_name, :string
  end
end
