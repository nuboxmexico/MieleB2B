class AddDispatchGroupReferencesToDispatchGuide < ActiveRecord::Migration[5.2]
  def change
    add_reference :dispatch_guides, :dispatch_group, foreign_key: true
  end
end
