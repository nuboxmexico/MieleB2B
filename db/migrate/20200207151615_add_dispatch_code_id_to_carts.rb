class AddDispatchCodeIdToCarts < ActiveRecord::Migration[5.2]
  def change
    change_table(:carts) do |t|
      t.references :dispatch_code, foreign_key: { to_table: 'promotional_codes' }
    end
  end
end
