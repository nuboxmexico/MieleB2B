class DispatchInstructionsFile < ApplicationRecord
  belongs_to :quotation

  has_attached_file :file
  validates_attachment_file_name :file, matches: [/.xls\z/i, /.xlsx\z/i, /.png\z/i, /.jpg\z/i, /.jpeg\z/i, /.pdf\z/i]
end
