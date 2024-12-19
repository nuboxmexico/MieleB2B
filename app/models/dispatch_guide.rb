class DispatchGuide < ApplicationRecord
	belongs_to :quotation
  belongs_to :role

	has_attached_file :document
	validates_attachment_content_type :document, content_type: ['application/pdf']

  validates :quotation, presence: { message: 'no puede estar vacío' }
end
