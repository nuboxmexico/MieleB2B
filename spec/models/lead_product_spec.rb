require 'rails_helper'

RSpec.describe LeadProduct, type: :model do
  let(:product){create(:lead_product, unit_price: 1000, quantity: 3)}

  context 'get' do 
    it 'total price' do 
      expect(product.total_price).to be (product.unit_price.to_f * product.quantity)
    end
  end
end
