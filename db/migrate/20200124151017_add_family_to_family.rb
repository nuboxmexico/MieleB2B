class AddFamilyToFamily < ActiveRecord::Migration[5.2]
  def change
    add_reference :families, :family, foreign_key: true
  end
end
