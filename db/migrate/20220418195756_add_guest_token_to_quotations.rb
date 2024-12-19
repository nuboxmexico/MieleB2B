class AddGuestTokenToQuotations < ActiveRecord::Migration[5.2]
  def change
    add_column :quotations, :guest_token, :string
  end
end
