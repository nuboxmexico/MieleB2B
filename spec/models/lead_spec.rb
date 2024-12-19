require 'rails_helper'

RSpec.describe Lead, type: :model do
  let(:lead){create(:lead)}

  context 'get' do 
    it 'currency options' do 
      response = Lead.currency_options
      expect(response.class).to be Hash
      expect(response.size).to be 3
      expect(response.has_key?(:usd)).to be true
      expect(response.has_key?(:clp)).to be true
      expect(response.has_key?(:uf)).to be true
      expect(response[:usd]).to eq 'USD'
      expect(response[:clp]).to eq 'CLP'
      expect(response[:uf]).to eq 'UF'
    end

    it 'status options' do 
      response = Lead.status_options
      expect(response.class).to be Hash
      expect(response.size).to be 5
      expect(response.has_key?(:started)).to be true
      expect(response.has_key?(:on_track)).to be true
      expect(response.has_key?(:quoted)).to be true
      expect(response.has_key?(:canceled)).to be true
      expect(response.has_key?(:in_negotiation)).to be true
      expect(response[:started]).to eq 'Iniciado'
      expect(response[:on_track]).to eq 'En seguimiento'
      expect(response[:quoted]).to eq 'Cotizado'
      expect(response[:in_negotiation]).to eq 'En negociación'
    end

    it 'ordered products' do 
      sorted_products = lead.products.order(id: :asc)
      expect(lead.products.count).to be 2

      expect(lead.sorted_products[0]).to eq sorted_products[0]
      expect(lead.sorted_products[1]).to eq sorted_products[1]
    end

    it 'self status' do 
      expect(lead.status).to eq 'started'
      expect(lead.status_name).to eq 'Iniciado'
    end

    it 'products to quotation' do 
      official_product = create(:product)
      lead.products << create(:lead_product, sku: official_product.sku)

      expect(lead.products.count).to be 3
      expect(Product.where(sku: lead.products.pluck(:sku)).count).to be 1

      products = lead.products_to_quotation
      expect(products.count).to be 3
      expect(products.map{|product| product.class}).to eq [Product, Product, Product]
      expect(products.where(only_for_project: true).count).to be 2
      expect(products.where(only_for_project: false).count).to be 1
    end

    it 'existing skus' do 
      product = create(:product)
      lead.products << create(:lead_product, sku: product.sku)

      expect(lead.products.count).to be 3
      expect(Product.where(sku: lead.products.map{|l| l.sku}).count).to be 1

      existing_skus = lead.existing_skus
      expect(existing_skus.class).to be Hash
      expect(existing_skus.size).to be 1
      expect(existing_skus.has_key?(product.sku)).to be true
      expect(existing_skus[product.sku]).to be true
    end
  end
end
