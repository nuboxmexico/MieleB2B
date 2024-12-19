require 'rails_helper'

RSpec.describe Product, type: :model do
  context 'create' do
    it 'new to projects' do 
      lead_product_1 = create(:lead_product, sku: 'sku1-lead', unit_price: 10000, name: 'Primer Producto de Lead')
      lead_product_2 = create(:lead_product, sku: 'sku2-lead', unit_price: 5000, name: 'Segundo Producto de Lead', quantity: 2)

      expect(Product.count).to be 0
      expect(LeadProduct.count).to be 2

      Product.create_to_project_quotations([lead_product_1, lead_product_2])
      expect(Product.count).to be 2

      product_1 = Product.find_by(sku: 'sku1-lead')
      expect(product_1).not_to be nil
      expect(product_1.price).to be lead_product_1.unit_price
      expect(product_1.sku).to eq lead_product_1.sku
      
      product_2 = Product.find_by(sku: 'sku2-lead')
      expect(product_2).not_to be nil
      expect(product_2.price).to be lead_product_2.unit_price
      expect(product_2.sku).to eq lead_product_2.sku
    end
  end
end
