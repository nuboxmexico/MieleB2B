class QuotationProductsAux < ApplicationRecord
    belongs_to :product, -> { with_deleted }
    belongs_to :dispatch_group
end
