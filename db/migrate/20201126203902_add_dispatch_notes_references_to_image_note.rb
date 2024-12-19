class AddDispatchNotesReferencesToImageNote < ActiveRecord::Migration[5.2]
  def change
    add_reference :image_notes, :dispatch_note, foreign_key: true
  end
end
