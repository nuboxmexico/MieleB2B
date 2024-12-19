class AddBackupFileToPayment < ActiveRecord::Migration[5.2]
  def up
    add_attachment :payments, :backup_document
  end

  def down
    remove_attachment :payments, :backup_document
  end
end
