class Family < ApplicationRecord
	has_many :children, class_name: :Family, foreign_key: :family_id, dependent: :nullify
	belongs_to :parent, class_name: :Family, foreign_key: :family_id, dependent: :destroy

	has_many :product_families, dependent: :destroy
	has_many :products, through: :product_families
end
