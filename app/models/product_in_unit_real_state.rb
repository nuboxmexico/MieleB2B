class ProductInUnitRealState < ApplicationRecord
    belongs_to :quotation_product
    belongs_to :config_unit_real_state
end
