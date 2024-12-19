class UploadLog < ApplicationRecord
	default_scope{ order("created_at DESC") }
	belongs_to :user, -> { with_deleted }
end
