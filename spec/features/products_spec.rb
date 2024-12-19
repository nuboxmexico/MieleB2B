require 'rails_helper'
describe 'Product', type: :feature do 
	let(:user){create(:user)}
	let(:mca_seller_user){create(:mca_seller_user)}

	context 'View' do
		before do 
			login_as(user, scope: :user)
		end

		it 'search and add to cart', js: true do
			product = create(:product_2)
			family = create(:business_unit)
			family.products << product
			visit products_path(business_unit: family.name)
			expect(all('.card').length).to be 1

			first('.fa-cart-plus').click
			wait_for_ajax
			expect(page).to have_css("#items-in-cart", text: "1")
			sleep(1)
			expect(page).to have_content('Producto agregado con éxito')
		end

		it 'search and show', js: true do
			product = create(:product_2)
			family = create(:business_unit)
			family.products << product
			visit products_path(business_unit: family.name)
			expect(all('.card').length).to be 1

			within '.select2-miele' do
				find('.select2-container').click
			end

			find(".select2-search__field").set('Lavadora')

			within ".select2-results__options" do
				find('li', text: 'Lavadora').click
			end
			wait_for_ajax
			expect(page).to have_current_path(product_path(sku: product.sku))
		end

		it 'filter products by price', js: true do
			product = create(:product_with_families)
			product2 = create(:product_2)
			product3 = create(:product_3)
			family = Family.find_by(depth: 0)
			family.products << product2
			Family.find_by(depth: 1).products << product2
			family.products << product3
			visit products_path(business_unit: family.name)
			expect(page).to have_current_path(products_path(business_unit: family.name))
			expect(all('.card').length).to be 3
			page.execute_script('$("#max-value").val("800000");')
			page.execute_script('$("#min-value").trigger("change")')
			wait_for_ajax
			expect(all('.card').length).to be 1

			page.execute_script('$("#min-value").val("800000");')
			page.execute_script('$("#max-value").val("1449990");')
			page.execute_script('$("#min-value").trigger("change")')
			wait_for_ajax
			expect(all('.card').length).to be 2

			first('#family'+Family.find_by(depth: 1).id.to_s).click
			wait_for_ajax
			expect(all('.card').length).to be 2
			page.execute_script('$("#min-value").val("800000");')
			page.execute_script('$("#min-value").trigger("change")')
			wait_for_ajax
			expect(all('.card').length).to be 1

		end

		it 'filter products by family', js: true do
			Timecop.freeze(Date.new(2020, 04, 01))
			create(:sale_channel)
			create(:project_business_sale_channel)
			create(:own_retail_sale_channel)
			create(:retail_sale_channel)
			create(:ecommerce_sale_channel)

			product = create(:product_with_families)
			product2 = create(:product_2)
			product3 = create(:product_3)
			family = Family.find_by(depth: 0)
			family.products << product2
			family.products << product3
			discount_1 = create(:product_discount, product: product2)
			discount_1.sale_channels << SaleChannel.all
			discount_2 = create(:product_discount, product: product3, end_date: Date.new(2020, 03, 10))
			discount_2.sale_channels << SaleChannel.all

			visit products_path(business_unit: family.name)
			expect(all('.card').length).to be 3
			sleep(1)
			click_link("Ofertas")
			wait_for_ajax
			expect(all('.card').length).to be 1

			#Cocina
			first('#family'+Family.find_by(depth: 1).id.to_s).click
			wait_for_ajax
			expect(all('.card').length).to be 1

			#Todos
			first('#familyall').click
			wait_for_ajax
			expect(all('.card').length).to be 3

			Timecop.return
		end

		it 'show product detail', js: true do
			product = create(:product_with_families)
			visit product_path(sku: product.sku)
			expect(page).to have_current_path(product_path(sku: product.sku))
			expect(page).to have_content('Máquina de Café CM5300')
			expect(page).to have_content('TNR 105RR590')
			expect(page).to have_content('Máquina para el hogar')
			expect(page).to have_content('699.990')
		end

		it 'show product detail with offer', js: true do
			Timecop.freeze(Date.new(2020, 04, 01))
			product = create(:product_with_families)
			create(:product_discount, product: product)
			visit product_path(sku: product.sku)
			expect(page).to have_current_path(product_path(sku: product.sku))
			expect(page).to have_content('Máquina de Café CM5300')
			expect(page).to have_content('TNR 105RR590')
			expect(page).to have_content('Máquina para el hogar')
			expect(page).to have_content('$ 559.992')
			expect(page).to have_content('-20.0%')
			Timecop.return
		end

		it 'add to cart from show', js: true do
			product = create(:product_with_families)
			visit product_path(sku: product.sku)
			expect(page).to have_current_path(product_path(sku: product.sku))
			expect(page).to have_content('Máquina de Café CM5300')
			first('#increase').click
			first('#increase').click
			click_button('Cotizar')
			wait_for_ajax
			expect(page).to have_css("#items-in-cart", text: "3")
			sleep(1)
			expect(page).to have_content('Producto agregado con éxito')
		end

		it 'edit rich field', js: true do 
			product = create(:product_with_families)
			product.update(wash_program: 'Im testing')
			visit product_path(sku: product.sku)
			expect(page).to have_current_path(product_path(sku: product.sku))
			first('.pt28').click
			sleep(1)
			expect(page).to have_content('Im testing')
			first('.fa-pen').click
			sleep(1)
			within_frame("product_wash_program_ifr") do
				editor = page.find_by_id('tinymce')
				editor.native.send_keys ', now im ready'
			end
			click_button 'Guardar'
			wait_for_ajax
			expect(page).to have_content 'Im testing, now im ready'
			expect(Product.first.wash_program).to eq '<p>Im testing, now im ready</p>'
		end

		it 'filter by outlet', js: true do 
			product = create(:product_with_families)
			product2 = create(:product_2)
			product3 = create(:product_3, outlet: true)
			family = Family.find_by(depth: 0)
			family.products << product2
			family.products << product3

			visit products_path(business_unit: family.name)
			expect(all('.card').length).to be 3
			click_link('Outlet')
			wait_for_ajax
			expect(all('.card').length).to be 1

			page.execute_script('$("#max-value").val("50000");')
			page.execute_script('$("#max-value").trigger("change")')
			wait_for_ajax
			expect(all('.card').length).to be 0
		end
	end

	context 'Seller' do 
		before do 
			login_as(mca_seller_user, scope: :user)
		end
		it 'search and show', js: true do
			create(:project_business_sale_channel)
			create(:own_retail_sale_channel)
			create(:retail_sale_channel)
			create(:ecommerce_sale_channel)
			product = create(:product_with_families)
			product2 = create(:product_2)
			family = Family.find_by(depth: 0)
			family.products << product2
			product.sale_channels << SaleChannel.all
			product2.sale_channels << SaleChannel.find_by(name: 'E-commerce')
			
			visit products_path(business_unit: family.name)
			expect(page).to have_current_path(products_path(business_unit: family.name))

			expect(all('.card').length).to be 1

			within '.select2-miele' do
				find('.select2-container').click
			end

			find(".select2-search__field").set('Lavadora')

			expect(page).to have_content('No se encontraron resultados')
		end
	end

	context 'B-Stock' do
		before do 
			login_as(user, scope: :user)
			create(:product_with_families, bstock: true)
			create(:bstock_1)
			create(:bstock_2)
		end

		it 'show in list', js: true do
			family = Family.find_by(depth: 0)
			visit products_path(business_unit: family.name)
			expect(page).to have_current_path(products_path(business_unit: family.name))

			expect(page).to have_content('Todos [1]')
			expect(page).to have_content('B-Stock [2]')
			expect(all('.card').length).to be 1
			expect(page).to have_content('Máquina de Café CM5300 TNR 105RR590 699.990')
			click_link('B-Stock')
			wait_for_ajax
			expect(all('.card').length).to be 1
			expect(page).to have_content('Máquina de Café CM5300 TNR 105RR590 Desde $ 489.993')
		end

		it 'show and interact product', js: true do 
			visit bstock_product_path(sku: Product.first.sku)
			expect(page).to have_current_path(bstock_product_path(sku: Product.first.sku))
			expect(page).to have_content('Máquina de Café CM5300 TNR 105RR590')
			expect(page).to have_content('Desde $ 489.993')
			expect(page).to have_content('Categoría B2 - Falta filtros')
			expect(page).to have_content('B2 - KKOKSA123 - 30%')
			expect(page).to have_content('Disponible en Miele Point - Piedra Roja')
			page.all('select#bstock_id option').map(&:value) == %w(3 2)
			first('#add-to-cart').click
			expect(page).to have_content('Producto agregado con éxito')
			expect(page).to have_content('$ 559.992')
			page.all('select#bstock_id option').map(&:value) == %w(2)
			expect(page).to have_content('Categoría B1 - Falta perilla')
			expect(page).to have_content('B1 - MSKMAS12313 - 20%')
			expect(page).to have_content('Miele Experience Center')
			expect(Cart.first.cart_items.size).to eq 1
		end

		it 'try to add bstock after normal products', js: true do 
			create(:cart_with_product)
			visit bstock_product_path(sku: Product.first.sku)
			expect(page).to have_current_path(bstock_product_path(sku: Product.first.sku))
			expect(page).to have_content('Máquina de Café CM5300 TNR 105RR590')
			expect(page).to have_content('Disponible en Miele Point - Piedra Roja')
			expect(page).to have_css("#items-in-cart", text: "1")
			page.all('select#bstock_id option').map(&:value) == %w(3 2)
			first('#add-to-cart').click
			wait_for_ajax
			expect(page).to have_content('Solo puedes cotizar productos B-Stock con otros del mismo tipo.')
			expect(page).to have_css("#items-in-cart", text: "1")
			page.all('select#bstock_id option').map(&:value) == %w(3 2)
		end

		it 'try to add normal products after bstock', js: true do 
			visit bstock_product_path(sku: Product.first.sku)
			expect(page).to have_current_path(bstock_product_path(sku: Product.first.sku))
			expect(page).to have_content('Máquina de Café CM5300 TNR 105RR590')
			expect(page).to have_content('Disponible en Miele Point - Piedra Roja')
			expect(page).to have_css("#items-in-cart", text: "0")
			page.all('select#bstock_id option').map(&:value) == %w(3 2)
			first('#add-to-cart').click
			wait_for_ajax
			expect(page).to have_content('Producto agregado con éxito')
			expect(page).to have_css("#items-in-cart", text: "1")
			family = Family.find_by(depth: 0)
			visit products_path(business_unit: family.name)
			expect(page).to have_current_path(products_path(business_unit: family.name))
			first('.fa-cart-plus').click
			wait_for_ajax
			expect(page).to have_content('No es posible agregar el producto junto a otros de tipo B-Stock.')
			expect(page).to have_css("#items-in-cart", text: "1")
		end

		it 'add bstock and show cart', js: true do 
			visit bstock_product_path(sku: Product.first.sku)
			expect(page).to have_current_path(bstock_product_path(sku: Product.first.sku))
			expect(page).to have_content('Máquina de Café CM5300 TNR 105RR590')
			expect(page).to have_content('Disponible en Miele Point - Piedra Roja')
			expect(page).to have_css("#items-in-cart", text: "0")
			page.all('select#bstock_id option').map(&:value) == %w(3 2)
			first('#add-to-cart').click
			wait_for_ajax
			expect(page).to have_content('Producto agregado con éxito')
			expect(page).to have_css("#items-in-cart", text: "1")
			visit cart_path
			expect(page).to have_current_path(cart_path)
			expect(page).to have_content('Máquina de Café CM5300 - B2 - 30%')
			expect(page).to have_content('EAN: KKOKSA123')
			expect(page).to have_content('105RR590')
			expect(page).to have_content('489.993')
			expect(page).to have_content('Sub Total 489.993')
			expect(page).to have_content('489.993 (IVA Incluído)')
		end

		it 'list bstocks and delete one', js: true do 
			expect(Product.all.size).to eq 3
			visit bstocks_path
			expect(page).to have_current_path(bstocks_path)
			expect(page).to have_content('Máquina de Café CM5300 - MSKMAS12313 - 20%')
			expect(page).to have_content('Máquina de Café CM5300 - KKOKSA123 - 30%')
			expect(page).to have_content('$ 559.992')
			expect(page).to have_content('$ 489.993')
			expect(page).to have_button('Eliminar', disabled: true)
			first('.cr').click
			expect(page).to have_button('Eliminar', disabled: false)
			first('#sent-bstocks').click
			expect(page).to have_content('¿Esta seguro que desea borrar 1 productos B-stock de forma permanente del inventario?')
			first('.swal2-confirm').click

			expect(page).to have_current_path(bstocks_path)
			expect(page).not_to have_content('Máquina de Café CM5300 - MSKMAS12313 - 20%')
			expect(page).to have_content('Máquina de Café CM5300 - KKOKSA123 - 30%')
			expect(page).not_to have_content('$ 559.992')
			expect(page).to have_content('$ 489.993')
			expect(Product.all.size).to eq 2
			expect(page).to have_content('Productos B-Stock eliminados con éxito.')
		end
	end
end