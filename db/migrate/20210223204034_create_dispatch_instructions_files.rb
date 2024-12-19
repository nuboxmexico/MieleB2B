class CreateDispatchInstructionsFiles < ActiveRecord::Migration[5.2]
  def change
    create_table :dispatch_instructions_files do |t|
      t.references :quotation, foreign_key: true
      t.attachment :file

      t.timestamps
    end
  end
end
