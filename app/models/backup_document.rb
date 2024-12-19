class BackupDocument < ApplicationRecord
	belongs_to :quotation
	has_attached_file :document
	do_not_validate_attachment_file_type :document
end
