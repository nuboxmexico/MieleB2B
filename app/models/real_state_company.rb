class RealStateCompany < ApplicationRecord
    has_many :builder_companies
    has_many :quotations, through: :builder_companies

    validates :name, presence: true
end
