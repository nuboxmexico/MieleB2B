class AddInformationFieldsToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :specs, :text
    add_column :products, :features, :text
    add_column :products, :technical_specs, :text
    add_column :products, :product_functions, :text
    add_column :products, :drink_specialty, :text
    add_column :products, :basket_design, :text
    add_column :products, :wash_program, :text
    add_column :products, :dry_program, :text
    add_column :products, :maintenance_care, :text
    add_column :products, :security, :text
    add_column :products, :efficiency_sustain, :text
    add_column :products, :accessories, :text
  end
end
