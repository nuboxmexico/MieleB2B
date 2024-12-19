class CreateLeadAttachments < ActiveRecord::Migration[5.2]
  def change
    create_table :lead_attachments do |t|
      t.references :lead, foreign_key: true

      t.timestamps
    end
  end
end
