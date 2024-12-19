class CreateBackupDocuments < ActiveRecord::Migration[5.2]
  def change
    create_table :backup_documents do |t|
      t.attachment :document
      t.references :quotation, foreign_key: true

      t.timestamps
    end
  end
end
