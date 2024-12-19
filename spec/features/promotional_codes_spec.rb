require 'rails_helper'
describe 'Promotional Codes', type: :feature do 
	let(:user){create(:user)}

	context 'Administration' do
		before do
			login_as(user, scope: :user)
		end

		it 'create code for dispatch', js: true do
			create(:ecommerce_sale_channel)
			visit new_promotional_code_path
			expect(page).to have_current_path(new_promotional_code_path)
			expect(page).to have_content('Crear código')
			fill_in 'promotional_code_name', with: 'test code'
			fill_in 'promotional_code_description', with: 'this is a promotional code'
			fill_in 'promotional_code_code', with: 'RAS123'
			fill_in 'promotional_code_percent', with: 30
			fill_in 'promotional_code_use_limit', with: 40
			page.execute_script("$('#promotional_code_start_date').val('20/12/2020')")
			page.execute_script("$('#promotional_code_end_date').val('30/12/2020')")
			page.execute_script("$('#promotional_code_sale_channels').val('#{SaleChannel.last.id}')")
			page.execute_script("$('#promotional_code_sale_channels').trigger('change');")
			click_button('Crear código')
			expect(page).to have_current_path(promotional_codes_path)
			expect(page).to have_content('Código de descuento creado con éxito.')
			expect(page).to have_content('test code')
			expect(page).to have_content('RAS123')
			expect(page).to have_content('E-commerce')
			expect(page).to have_content('40')
			expect(page).to have_content('Despacho')
		end

		it 'create code for products', js: true do
			create(:ecommerce_sale_channel)
			visit new_promotional_code_path
			expect(page).to have_current_path(new_promotional_code_path)
			expect(page).to have_content('Crear código')
			fill_in 'promotional_code_name', with: 'test code'
			fill_in 'promotional_code_description', with: 'this is a promotional code'
			fill_in 'promotional_code_code', with: 'RAS123'
			fill_in 'promotional_code_percent', with: 30
			fill_in 'promotional_code_use_limit', with: 40
			page.execute_script("$('#promotional_code_start_date').val('20/12/2020')")
			page.execute_script("$('#promotional_code_end_date').val('30/12/2020')")
			page.execute_script("$('#promotional_code_sale_channels').val('#{SaleChannel.last.id}')")
			page.execute_script("$('#promotional_code_sale_channels').trigger('change');")
			first('.slider').click
			click_button('Crear código')
			expect(page).to have_current_path(promotional_codes_path)
			expect(page).to have_content('Código de descuento creado con éxito.')
			expect(page).to have_content('test code')
			expect(page).to have_content('RAS123')
			expect(page).to have_content('E-commerce')
			expect(page).to have_content('40')
			expect(page).to have_content('Productos')
		end

		it 'create code unlimited', js: true do
			create(:ecommerce_sale_channel)
			visit new_promotional_code_path
			expect(page).to have_current_path(new_promotional_code_path)
			expect(page).to have_content('Crear código')
			fill_in 'promotional_code_name', with: 'test code'
			fill_in 'promotional_code_description', with: 'this is a promotional code'
			fill_in 'promotional_code_code', with: 'RAS123'
			fill_in 'promotional_code_percent', with: 30
			page.execute_script("$('.cr').click()")
			page.execute_script("$('#promotional_code_start_date').val('20/12/2020')")
			page.execute_script("$('#promotional_code_end_date').val('30/12/2020')")
			page.execute_script("$('#promotional_code_sale_channels').val('#{SaleChannel.last.id}')")
			page.execute_script("$('#promotional_code_sale_channels').trigger('change');")
			click_button('Crear código')
			expect(page).to have_current_path(promotional_codes_path)
			expect(page).to have_content('Código de descuento creado con éxito.')
			expect(page).to have_content('test code')
			expect(page).to have_content('RAS123')
			expect(page).to have_content('E-commerce')
			expect(page).to have_content('Ilimitado')
		end
	end

	context 'Use' do
		before do
			login_as(user, scope: :user)
		end

		after do 
			Timecop.return
		end

		it 'in cart when is valid and splitting total', js: true do
			Timecop.freeze(Date.new(2020, 02, 01))
			user = create(:seller_user)
			login_as(user, scope: :user)

			create(:promotional_code)
			create(:cart_in_last_level, user: user)
			visit cart_path 
			first('#promotional-tab').click
			sleep(1)
			fill_in 'code', with: '30OFF'
			click_button('Aplicar')
			wait_for_ajax
			expect(page).to have_content('Código descuento 30OFF (-30%)')
			expect(page).to have_content('- 9.659.862')
			within '#cart-total-cost-1' do
				expect(page).to have_content('22.539.678')
			end

			sleep(2)
			expect(page).to have_content('Descuento aplicado con éxito')

			first('#pay-50').click
			wait_for_ajax

			within '#cart-total-cost-1' do
				expect(page).to have_content('22.539.678,0 (IVA Incluído)')
			end
			within '#cart-deb-1' do
				expect(page).to have_content('Saldo: 11.269.839')
			end
		end

		it 'in cart when is valid and had unlimited uses', js: true do
			Timecop.freeze(Date.new(2020, 02, 01))
			user = create(:seller_user)
			login_as(user, scope: :user)

			create(:unlimited_code)
			create(:cart_in_last_level, user: user)
			visit cart_path 
			first('#promotional-tab').click
			sleep(1)
			fill_in 'code', with: '30OFF'
			click_button('Aplicar')
			wait_for_ajax
			expect(page).to have_content('Código descuento 30OFF (-30%)')
			expect(page).to have_content('- 9.659.862')
			within '#cart-total-cost-1' do
				expect(page).to have_content('22.539.678,0 (IVA Incluído)')
			end

			sleep(2)
			expect(page).to have_content('Descuento aplicado con éxito')

			first('#pay-50').click
			wait_for_ajax

			within '#cart-total-cost-1' do
				expect(page).to have_content('22.539.678,0 (IVA Incluído)')
			end
			within '#cart-deb-1' do
				expect(page).to have_content('Saldo: 11.269.839')
			end
		end

		it 'in cart when is expired', js: true do
			Timecop.freeze(Date.new(2020, 03, 01))
			create(:promotional_code)
			create(:cart_in_last_level)
			visit cart_path 
			first('#promotional-tab').click
			sleep(1)
			fill_in 'code', with: '30OFF'
			click_button('Aplicar')
			wait_for_ajax
			expect(page).to have_content('El código que ingresaste ya no es válido')
		end

		it 'in cart when isnt more uses', js: true do
			Timecop.freeze(Date.new(2020, 02, 01))
			create(:promotional_code, use_limit: 0)
			create(:cart_in_last_level)
			visit cart_path 
			first('#promotional-tab').click
			sleep(1)
			fill_in 'code', with: '30OFF'
			click_button('Aplicar')
			wait_for_ajax
			expect(page).to have_content('El código que ingresaste excedió el número de usos')
		end

		it 'in cart when isnt for products', js: true do
			Timecop.freeze(Date.new(2020, 02, 01))
			create(:promotional_code, use_limit: 0, is_for_product: false)
			create(:cart_in_last_level)
			visit cart_path 
			first('#promotional-tab').click
			sleep(1)
			fill_in 'code', with: '30OFF'
			click_button('Aplicar')
			wait_for_ajax
			expect(page).to have_content('El código que ingresaste no aplica a productos.')
		end

		it 'in cart when code not exists', js: true do
			Timecop.freeze(Date.new(2020, 02, 01))
			create(:cart_in_last_level)
			visit cart_path 
			first('#promotional-tab').click
			sleep(1)
			fill_in 'code', with: '30OFF'
			click_button('Aplicar')
			wait_for_ajax
			expect(page).to have_content('El código que ingresaste no existe.')
		end
	end
end