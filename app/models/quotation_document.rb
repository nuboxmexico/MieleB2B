class QuotationDocument < ApplicationRecord
	belongs_to :quotation
	
	has_attached_file :document
	validates_attachment_content_type :document, :content_type => ["application/pdf"]
end
