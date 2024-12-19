class DetailQuotationProduct < ApplicationRecord
    belongs_to :quotation_product
    belongs_to :dispatch_group

    def self.string_ids_to_object(ids)
        detail_quotation_products = []
        ids.split(',').each do |id|
            detail_quotation_products.push(DetailQuotationProduct.find(id))
        end
        return detail_quotation_products
    end
end
