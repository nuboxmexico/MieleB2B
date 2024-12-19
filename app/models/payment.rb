class Payment < ApplicationRecord
	acts_as_paranoid
	scope :completed, -> {where(state: 'complete')}
	belongs_to :quotation
  has_attached_file :backup_document
  validates_attachment_file_name :backup_document, matches: [/.xls\z/i, /.xlsx\z/i, /.png\z/i, /.jpg\z/i, /.pdf\z/i]

	before_create :set_tx_code

	private

	def set_tx_code
		self.miele_tx_code = 'MPP'+Time.now.to_i.to_s
	end
end
