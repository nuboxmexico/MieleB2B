class AddMdaAMdaBMdaCSdaASdaBSdaCPaiAToRegions < ActiveRecord::Migration[5.2]
  def change
    add_column :regions, :mda_a, :integer
    add_column :regions, :mda_b, :integer
    add_column :regions, :mda_c, :integer
    add_column :regions, :sda_a, :integer
    add_column :regions, :sda_b, :integer
    add_column :regions, :sda_c, :integer
    add_column :regions, :pai_a, :integer
  end
end
