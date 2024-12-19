class Commune < ApplicationRecord
  belongs_to :region
  has_many   :dispatch_quotations, class_name: "Quotation", foreign_key: "dispatch_commune_id", dependent: :nullify   
  has_many   :personal_quotations, class_name: "Quotation", foreign_key: "personal_commune_id", dependent: :nullify
  has_many   :instalation_quotations, class_name: "Quotation", foreign_key: "instalation_commune_id", dependent: :nullify
  has_many   :billing_quotations, class_name: "Quotation", foreign_key: "billing_commune_id", dependent: :nullify
  #has_many   :addresses, dependent: :destroy

  def name_with_region
    "#{name}, #{region.try(:name)}" 
  end
end
