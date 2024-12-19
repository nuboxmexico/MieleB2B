require 'rails_helper'
describe 'Retail Flow', type: :feature do 
	let(:retail_user){create(:retail_user)}

	context 'Create' do
		before do 
			login_as(retail_user, scope: :user)
			create(:providencia)
			create(:ingresada)
			create(:falabella)
			create(:linio)
			create(:travel)
			create(:paris)
			create(:bci)
			create(:itau)
			create(:hbt)
		end

		it 'quotation by retail user', js: true do 
			product = create(:product)
			product_2 = create(:product_2)
			product.retail_products << create(:retail_product, retail: Retail.first, tnr: 'ABC123')
			product_2.retail_products << create(:retail_product, retail: Retail.first, tnr: '12983192')
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			attach_file('oc_retail_load', Rails.root + "spec/aux/plantilla_oc_retail_1.xlsx", make_visible: true)
			first('#load-oc-retail').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Ocs de retail cargados con éxito.')

			expect(Quotation.all.size).to eq 1
			expect(Quotation.last.name).to eq 'Test garaje'
			expect(Quotation.last.receiver_name).to eq 'Ofertus'
			expect(Quotation.last.upc).to eq '21938019283091'
			expect(Quotation.last.dispatch_value).to eq 30000
			expect(Quotation.last.dispatch_commune).to eq Commune.last
			expect(Quotation.last.quotation_products.size).to eq 1
			expect(Quotation.last.quotation_products.last.product).to eq product
			expect(Quotation.last.quotation_products.last.quantity).to eq 20
			expect(Quotation.last.quotation_products.last.price).to eq 879000
			expect(Quotation.last.quotation_products.last.packing).to eq 1
			expect(Quotation.last.quotation_products.last.branch_name).to eq 'PARQUE ARAUCO'
			expect(Quotation.last.quotation_products.last.branch_number).to eq '24'

			attach_file('oc_retail_load', Rails.root + "spec/aux/plantilla_oc_retail_2.xlsx", make_visible: true)
			first('#load-oc-retail').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Ocs de retail cargados con éxito.')

			expect(Quotation.all.size).to eq 1
			expect(Quotation.last.name).to eq 'Test garaje'
			expect(Quotation.last.receiver_name).to eq 'Grange'
			expect(Quotation.last.dispatch_value).to eq 40000
			expect(Quotation.last.dispatch_commune).to eq Commune.last
			expect(Quotation.last.quotation_products.size).to eq 2
			expect(Quotation.last.quotation_products.first.product).to eq product
			expect(Quotation.last.quotation_products.first.quantity).to eq 4
			expect(Quotation.last.quotation_products.first.price).to eq 50000
			expect(Quotation.last.quotation_products.first.packing).to eq 1
			expect(Quotation.last.quotation_products.first.branch_number).to eq '24'
			expect(Quotation.last.quotation_products.first.branch_name).to eq 'PARQUE ARAUCO'
			expect(Quotation.last.quotation_products.last.product).to eq product_2
			expect(Quotation.last.quotation_products.last.quantity).to eq 20
			expect(Quotation.last.quotation_products.last.price).to eq 879000
			expect(Quotation.last.quotation_products.last.packing).to eq 1
			expect(Quotation.last.quotation_products.last.branch_number).to eq '20'
			expect(Quotation.last.quotation_products.last.branch_name).to eq 'ALTO'
		end
	end

	context 'Manager' do
		before do 
			login_as(retail_user, scope: :user)
			create(:falabella)
			create(:linio)
		end

		it 'cant access to cart', js: true do 
			visit cart_path
			expect(page).to have_current_path(root_path)
			expect(page).to have_content('Acceso no autorizado.')
		end

		it 'visit quotations by retail', js: true do
			quotation = create(:retail_quotation)
			Product.first.retail_products << create(:retail_product, retail: Retail.first, tnr: 'ABC123')

			visit(quotations_path(retail: Retail.first.name))
			expect(page).to have_current_path(quotations_path(retail: Retail.first.name))

			expect(all('.panel').length).to be 1

			visit(quotations_path(retail: Retail.last.name))
			expect(page).to have_current_path(quotations_path(retail: Retail.last.name))
			
			expect(all('.panel').length).to be 0
		end
	end
end