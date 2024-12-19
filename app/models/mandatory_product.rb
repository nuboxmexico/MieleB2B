class MandatoryProduct < ApplicationRecord
	belongs_to :product
	belongs_to :instalation
end
