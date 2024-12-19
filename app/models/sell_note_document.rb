class SellNoteDocument < ApplicationRecord
	belongs_to :quotation
	has_attached_file :document
	validates_attachment_file_name :document, matches: [/.xls\z/i, /.xlsx\z/i, /.png\z/i, /.jpg\z/i, /.pdf\z/i]
end
