require 'rails_helper'
describe 'Data Upload', type: :feature do 
	let(:user){create(:user)}
	let(:retail_user){create(:retail_user)}

	context 'Products' do
		before do
			login_as(user, scope: :user)
		end
		it 'load images', js: true do
			product = create(:product_with_families)
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			attach_file('product_photo_upload', Rails.root + "spec/aux/105RR590.png", make_visible: true)
			first('#load-product-images').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Imágenes cargadas con éxito.')
			visit product_path(sku: product.sku)
			expect(page.first('.product-image')['src']).to include('105RR590.png')
		end

		it 'load mandatories', js: true do
			product_1 = create(:product)
			product_2 = create(:product_2)
			product_3 = create(:product_3)
			product_4 = create(:product_4)
			product_5 = create(:product_5)
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			attach_file('mandatory_load', Rails.root + "spec/aux/plantilla_mandatorios.xlsx", make_visible: true)
			first('#load-mandatories').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Productos mandatorios cargados con éxito.')
			expect(product_1.instalations.size).to eq 2
			expect(product_2.instalations.size).to eq 1
			expect(product_1.instalations.last.products.size). to eq 1
			expect(product_1.instalations.first.products.size). to eq 2

			expect(product_2.instalations.first.products.size). to eq 1
		end

		it 'load products', js: true do
			create(:sale_channel)
			create(:project_business_sale_channel)
			create(:own_retail_sale_channel)
			create(:retail_sale_channel)
			create(:ecommerce_sale_channel)
			create(:washing_machines)
			create(:accesories)
			product_1 = create(:product_with_families)
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			attach_file('products_load', Rails.root + "spec/aux/plantilla_productos.xlsx", make_visible: true)
			first('#load-products').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Productos cargados con éxito.')

			expect(Product.first.name).to eq 'Máquina de Café CM200'
			expect(Product.first.description).to eq 'producto bonito'
			expect(Product.first.price).to eq 1001000
			expect(Product.first.families.size).to eq 3
			expect(Product.first.product_type).to eq 'SDA'
			expect(Product.first.bstock).to eq true
			expect(Product.first.sale_channels.size).to eq 1

			expect(Product.second.name).to eq 'Lavadora A-123 super duper'
			expect(Product.second.description).to eq 'lavadora bakan para todo lo que quieras'
			expect(Product.second.price).to eq 1900900
			expect(Product.second.families.size).to eq 1
			expect(Product.second.can_retire).to eq true
			expect(Product.second.profit_center).to eq false
			expect(Product.second.sale_channels.size).to eq 5

			expect(Product.third.name).to eq 'Secadora c/tornillos'
			expect(Product.third.sku).to eq 'SEC456'
			expect(Product.third.description).to eq 'secado super rapido'
			expect(Product.third.dispatch).to eq true
			expect(Product.third.profit_center).to eq true
			expect(Product.third.sale_channels.size).to eq 1

			expect(Product.fourth.name).to eq 'Horno super increible'
			expect(Product.fourth.sku).to eq 'HOR789'
			expect(Product.fourth.description).to eq 'Horno de hierro'
			expect(Product.fourth.dispatch).to eq true
			expect(Product.fourth.mandatory).to eq false
			expect(Product.fourth.product_type).to eq 'MDA'
			expect(Product.fourth.sale_channels.size).to eq 1

			expect(Product.last.sku).to eq '105RR590'
			expect(Product.last.ean).to eq 'SAS908ASD08'
			expect(Product.last.discount).to eq 20
			expect(Product.last.cost_center.code).to eq 36
			expect(Product.last.state).to eq 'Falta perilla'

			expect(Product.all.size).to eq 6
			expect(Family.all.size).to eq 18

			expect(Family.find_by(name:'Cocina').children.find_by(name: 'Cocción')).not_to be nil
		end

		it 'load stock', js: true do
			product_1 = create(:product)
			product_2 = create(:product_2)
			product_3 = create(:product_3)
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			expect(all('.fa-eye').size).to eq 0
			attach_file('stock_load', Rails.root + "spec/aux/plantilla_stock.xlsx", make_visible: true)
			first('#load-stock').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Información de stock cargada con éxito.')

			expect(Product.find_by(sku: product_1.sku).stock).to eq 4
			expect(Product.find_by(sku: product_2.sku).stock).to eq 0
			expect(Product.find_by(sku: product_3.sku).stock).to eq 20

			expect(Product.find_by(sku: product_1.sku).stock_break).to eq true
			expect(Product.find_by(sku: product_2.sku).stock_break).to eq false
			expect(Product.find_by(sku: product_3.sku).stock_break).to eq true
			expect(UploadLog.all.size).to eq 1
			expect(all('.fa-eye').size).to eq 1
			find('.fa-eye').hover
			expect(page).to have_content('plantilla_stock.xlsx')
			expect(page).to have_content("(Subido el día #{UploadLog.last.created_at.strftime("%d/%m/%Y %H:%M")} por #{user.fullname})")
		end

		it 'load technical images', js: true do 
			product = create(:product)
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			attach_file('technical_images_upload', Rails.root + "spec/aux/105RR590_ins.png", make_visible: true)
			first('#load-technical-images').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Imágenes técnicas cargadas con éxito.')
			expect(product.technical_images.size).to eq 1
		end

		it 'load comparator info', js: true do
			product_1 = create(:product)
			product_2 = create(:product_2)
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			attach_file('comparator_load', Rails.root + "spec/aux/plantilla_comparador.xlsx", make_visible: true)
			first('#load-comparator').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Información del comparador cargada con éxito.')

			expect(product_1.comparable_attributes.size).to eq 10
			expect(product_1.product_attributes.size).to eq 10

			expect(product_2.comparable_attributes.size).to eq 8
			expect(product_2.product_attributes.size).to eq 8
		end

		it 'load discounts', js: true do
			Timecop.freeze(Date.new(2020, 04, 10))
			product_1 = create(:product)
			product_2 = create(:product_2)
			product_3 = create(:product_3)
			create(:product_discount, product: product_2)
			create(:product_discount, product: product_3)
			create(:ecommerce_sale_channel)
			create(:own_retail_sale_channel)
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			attach_file('discounts_load', Rails.root + "spec/aux/plantilla_descuentos.xlsx", make_visible: true)
			first('#load-discounts').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Descuentos cargados con éxito.')
			expect(Product.first.display_price(user)[1]).to eq product_1.price*0.8
			expect(Product.first.product_discount.sale_channels.size).to eq 2
			expect(Product.second.product_discount).to eq nil
			expect(Product.third.display_price(user)[1]).to eq product_3.price*0.5
			expect(Product.third.product_discount.sale_channels.size).to eq 1
			Timecop.return
		end

		it 'load cost centers', js: true do
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			attach_file('cost_center_load', Rails.root + "spec/aux/plantilla_cost_center.xlsx", make_visible: true)
			first('#load-cost-centers').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Centros de costo cargados con éxito.')

			expect(CostCenter.first.code).to eq 36
			expect(CostCenter.first.name).to eq 'Webshop'

			expect(CostCenter.last.code).to eq 22
			expect(CostCenter.last.name).to eq 'Miele Experience Center'
		end

		it 'load miele roles', js: true do
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			expect(MieleRole.all.size).to eq 1
			attach_file('miele_role_load', Rails.root + "spec/aux/plantilla_id_usuarios.xlsx", make_visible: true)
			first('#load-miele-roles').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('ID de usuarios cargados con éxito.')
			expect(MieleRole.all.size).to eq 2
			expect(MieleRole.find_by(code: '618')).to eq nil
			expect(MieleRole.find_by(code: 'MK').name).to eq 'MCA - MK'
			expect(MieleRole.find_by(code: 'MK').classification).to eq 'B'
			expect(MieleRole.find_by(code: '20').name).to eq 'B-Stock'
			expect(MieleRole.find_by(code: '20').classification).to eq nil
		end

		it 'load commissions table', js: true do
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			attach_file('commissions_load', Rails.root + "spec/aux/plantilla_comisiones.xlsx", make_visible: true)
			first('#load-commissions').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Tramos de comisiones cargados con éxito.')
			expect(CommissionParameter.all.size).to eq 4
			expect(CommissionParameter.first.lower_bound).to eq 0
			expect(CommissionParameter.first.level_a).to eq 17
			expect(CommissionParameter.second.upper_bound).to eq 16_999_999
			expect(CommissionParameter.second.level_b).to eq 18
			expect(CommissionParameter.third.lower_bound).to eq 17_000_000
			expect(CommissionParameter.third.level_c).to eq 19
			expect(CommissionParameter.fourth.upper_bound).to eq 1_000_000_000
			expect(CommissionParameter.fourth.level_b).to eq 22
		end

		it 'load commissions table fail in correlative rows', js: true do
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			attach_file('commissions_load', Rails.root + "spec/aux/plantilla_comisiones fail_1.xlsx", make_visible: true)
			first('#load-commissions').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Ha ocurrido un problema al cargar los tramos de comisiones.')
			expect(CommissionParameter.all.size).to eq 0
		end

		it 'load commissions table fail in segment row', js: true do
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			attach_file('commissions_load', Rails.root + "spec/aux/plantilla_comisiones fail_2.xlsx", make_visible: true)
			first('#load-commissions').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('Ha ocurrido un problema al cargar los tramos de comisiones.')
			expect(CommissionParameter.all.size).to eq 0
		end

		it 'download stock', js: true do 
			create(:product)
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#download-stock').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_stock_'+Date.today.strftime("%d/%m/%Y")+'.xlsx"'
			Capybara.use_default_driver
		end

		it 'download products', js: true do 
			create(:product)
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#download-products').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_productos_'+Date.today.strftime("%d/%m/%Y")+'.xlsx"'
			Capybara.use_default_driver
		end

		it 'download discounts', js: true do 
			create(:product_discount, product: create(:product))
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#download-discounts').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_descuentos_'+Date.today.strftime("%d/%m/%Y")+'.xlsx"'
			Capybara.use_default_driver
		end

		it 'download users ids', js: true do 
			create(:miele_role)
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#download-miele-roles').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_id_usuarios_'+Date.today.strftime("%d/%m/%Y")+'.xlsx"'
			Capybara.use_default_driver
		end

		it 'download cost centers', js: true do 
			create(:product_discount, product: create(:product))
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#download-cost-center').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_cost_center_'+Date.today.strftime("%d/%m/%Y")+'.xlsx"'
			Capybara.use_default_driver
		end

		it 'download commissions info', js: true do 
			create(:commission_parameter, lower_bound: 0, upper_bound: 6000000, level_a: 20, level_b:19, level_c: 18)
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#download-commissions-table').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_comisiones_'+Date.today.strftime("%d/%m/%Y")+'.xlsx"'
			Capybara.use_default_driver
		end

		it 'download commissions template', js: true do
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#commissions-template').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_comisiones.xlsx"'
			Capybara.use_default_driver
		end

		it 'download miele roles template', js: true do
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#miele-roles-template').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_id_usuarios.xlsx"'
			Capybara.use_default_driver
		end

		it 'download mandatory template', js: true do
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#mandatory-template').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_mandatorios.xlsx"'
			Capybara.use_default_driver
		end

		it 'download products template', js: true do
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#products-template').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_productos.xlsx"'
			Capybara.use_default_driver
		end

		it 'download stock template', js: true do
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#stock-template').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_stock.xlsx"'
			Capybara.use_default_driver
		end

		it 'download comparator template', js: true do
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#comparator-template').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_comparador.xlsx"'
			Capybara.use_default_driver
		end

		it 'download discounts template', js: true do
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#products-discounts-template').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_descuentos.xlsx"'
			Capybara.use_default_driver
		end

		it 'download cost center template', js: true do
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#cost-center-template').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_cost_center.xlsx"'
			Capybara.use_default_driver
		end
	end

	context 'Retail' do 
		before do
			login_as(retail_user, scope: :user)
			create(:falabella)
			create(:linio)
			create(:travel)
			create(:paris)
			create(:bci)
			create(:itau)
			create(:hbt)
		end

		it 'load tnr homologated', js: true do
			product = create(:product)
			product.retail_products << create(:retail_product, retail: Retail.first, tnr: 'ABC123')
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			attach_file('tnr_retail_load', Rails.root + "spec/aux/plantilla_tnr_retail.xlsx", make_visible: true)
			first('#load-tnr-retail').click
			expect(page).to have_current_path(upload_info_path)
			expect(page).to have_content('TNRs retail cargados con éxito.')

			expect(product.retail_products.size).to be 7
			expect(product.retail_products[0].tnr).to eq '19283'
			expect(product.retail_products[1].tnr).to eq '788882'
			expect(product.retail_products[2].tnr).to eq '10212'
			expect(product.retail_products[3].tnr).to eq '1222'
			expect(product.retail_products[4].tnr).to eq 'BCI123'
			expect(product.retail_products[5].tnr).to eq 'ITAU123'
			expect(product.retail_products[6].tnr).to eq 'HBT123'
		end

		it 'download oc template', js: true do
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#oc-template').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_oc_retail.xlsx"'
			Capybara.use_default_driver
		end

		it 'download tnr homologate template', js: true do
			Capybara.current_driver = :webkit
			visit upload_info_path
			expect(page).to have_current_path(upload_info_path)
			first('#homologate-template').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="plantilla_tnr_retail.xlsx"'
			Capybara.use_default_driver
		end
	end
end