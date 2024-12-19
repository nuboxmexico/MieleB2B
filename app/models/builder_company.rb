class BuilderCompany < ApplicationRecord
  belongs_to :real_state_company
  has_many :quotations

  validates :name, :rut, :sector, presence: true
end
