class AddUserTypeToDocs < ActiveRecord::Migration[5.2]
  def change
  	add_column :billing_documents, :user_type, :string, default: 'seller'
  	add_column :payment_documents, :user_type, :string, default: 'seller'
  end
end
