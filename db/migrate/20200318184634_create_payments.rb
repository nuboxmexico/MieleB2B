class CreatePayments < ActiveRecord::Migration[5.2]
  def change
    create_table :payments do |t|
      t.string :description
      t.integer :ammount
      t.datetime :pay_date
      t.boolean :verified
      t.string :tbk_transaction_id
      t.string :tbk_token
      t.string :state
      t.string :webpay_data
      t.string :miele_tx_code
      t.references :quotation, foreign_key: true

      t.timestamps
    end
  end
end
