class QuotationNote < ApplicationRecord
	default_scope{ order(created_at: :desc) }
	scope :instalation, -> {where(note_type: 'instalation')}
	scope :dispatch, -> {where(note_type: 'dispatch')}
	scope :home_program, -> {where(note_type: 'home program')}
	scope :finance, -> {where(note_type: 'finance')}
	
	belongs_to :user
	belongs_to :quotation
	has_many :image_notes
end
