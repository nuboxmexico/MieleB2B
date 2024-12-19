class AddCommunesInQuotation < ActiveRecord::Migration[5.2]
  def change
    change_table(:quotations) do |t|
      t.references :dispatch_commune, foreign_key: { to_table: 'communes' }
      t.references :personal_commune, foreign_key: { to_table: 'communes' }
    end
  end
end
