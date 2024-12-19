class CreateUploadLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :upload_logs do |t|
      t.string :file_name
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
