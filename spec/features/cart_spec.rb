require 'rails_helper'
describe 'Cart', type: :feature do 
	let(:user){create(:user)}

	context 'View' do
		before do 
			login_as(user, scope: :user)
		end
		it 'add and substract item', js: true do 
			create(:cart_with_product_next_level)
			visit cart_path

			expect(page).to have_content('Sub Total Dcto. por Tramo -5% 7.699.890 -384.989')
			within '#cart-total-cost-1' do
				expect(page).to have_content('7.314.901 (IVA Incluído)')
			end
			within '#indicator' do
				expect(page).to have_content('9.300.110 10 %')
			end
			# restamos uno
			first('#btn-minus-'+CartItem.last.id.to_s).click
			wait_for_ajax

			#open_screenshot
			expect(page).to have_content('Sub Total 6.999.900,0 Porcentaje de adelanto Aplicar descuentos OFF ON 6.999.900,0 (IVA Incluído')
			within '#cart-total-cost-1' do
				expect(page).to have_content('6.999.900,0 (IVA Incluído)')
			end
			within '#indicator' do
				expect(page).to have_content('100,0 5 %')
			end

			first('#btn-plus-'+CartItem.last.id.to_s).click
			wait_for_ajax

			expect(page).to have_content('Sub Total Dcto. por Tramo -5.0% 7.699.890,0 -384.989,0')
			within '#cart-total-cost-1' do
				expect(page).to have_content('7.314.901,0 (IVA Incluído)')
			end
			within '#indicator' do
				expect(page).to have_content('9.300.110,0 10 %')
			end
		end

		it 'delete a product from cart', js: true do
			create(:cart_with_product_next_level)
			visit cart_path
			expect(page).to have_current_path(cart_path)
			first(".remove-#{CartItem.last.id}").click
			click_button('Eliminar')
			wait_for_ajax
			expect(page).to have_content('Producto eliminado con éxito')
			expect(page).to have_content('Aún no tienes productos asociados a tu cotización')
		end

		it 'empty', js: true do
			create(:cart_with_product_next_level)
			visit cart_path
			expect(page).to have_current_path(cart_path)
			first('#empty-cart').click
			click_button('Vaciar')
			wait_for_ajax

			expect(page).to have_content('Aún no tienes productos asociados a tu cotización')

			expect(page).to have_content('Carro vaciado con éxito')
		end

		it 'with 50% of pay', js: true do
			user = create(:seller_user)
			login_as(user, scope: :user)
			create(:cart_with_product_next_level, user: user)
			visit cart_path

			expect(page).to have_content('Sub Total Dcto. por Tramo -5% 7.699.890 -384.989')
			within '#cart-total-cost-1' do
				expect(page).to have_content('7.314.901 (IVA Incluído)')
			end
			within '#indicator' do
				expect(page).to have_content('9.300.110 10 %')
			end

			first('#pay-50').click
			wait_for_ajax

			within '#cart-total-cost-1' do
				expect(page).to have_content('7.314.901,0 (IVA Incluído)')
			end
			within '#cart-deb-1' do
				expect(page).to have_content('Saldo: 3.657.450,5')
			end
			expect(Cart.last.pay_percent).to eq 50
			expect(page).to have_content('El o los productos serán despachados solo posterior al pago del 50% restante 3 días hábiles antes de la fecha elegida para despacho.')
			first('#continue-link').click

			within '#cart-total-cost-1' do
				expect(page).to have_content('3.657.450,5 (IVA Incluído)')
			end
			within '#cart-deb-1' do
				expect(page).to have_content('Saldo: 3.657.450,5')
			end
		end

		it 'turn off and on discounts', js: true do
			create(:cart_with_product_next_level, apply_discount: false)
			visit cart_path

			expect(page).to have_content('Sub Total 7.699.890 Porcentaje de adelanto Aplicar descuentos OFF ON 7.699.890 (IVA Incluído)')
			sleep(1)
			expect(page).not_to have_css('#indicator')

			first('#toggle-discounts').click
			wait_for_ajax
			cart = Cart.first
			expect(cart.apply_discount).to be true
			expect(cart.total_section_discount).to be > 0
			expect(page).to have_css('#indicator')
			expect(page).to have_content('9.300.110,0 10 %')
			expect(page).to have_content('Sub Total Dcto. por Tramo -5.0% 7.699.890,0 Porcentaje de adelanto Aplicar descuentos OFF ON 7.314.901,0 (IVA Incluído)')
		end

		it 'change instalation and dispatch checks', js: true do 
			create(:cart_with_product_next_level)
			visit cart_path
			expect(page).to have_current_path(cart_path)
			first("#dispatch#{CartItem.last.id}-false").click
			wait_for_ajax
			expect(CartItem.last.dispatch).to eq false
			first("#instalation#{CartItem.last.id}-false").click
			wait_for_ajax
			expect(CartItem.last.instalation).to eq false
		end

		it 'add and delete home program with instalation', js: true do 
			create(:cart_with_product_next_level)
			create(:home_program_product)
			Cart.last.cart_items.last.update(instalation: false)
			visit cart_path
			expect(page).to have_css("#items-in-cart", text: "11")
			expect(page).to have_content('7.314.901 (IVA Incluído)')
			# agrego home program
			first("#instalation#{CartItem.first.id}-true").click
			wait_for_ajax
			sleep(5)
			expect(CartItem.first.instalation).to eq true
			expect(page).to have_content('Home Program')
			expect(page).to have_content('7.414.891,0 (IVA Incluído)')
			expect(page).to have_css("#items-in-cart", text: "12")
			# quito home program
			first("#instalation#{CartItem.first.id}-false").click
			wait_for_ajax
			sleep(5)
			expect(CartItem.first.instalation).to eq false
			expect(page).to have_css("#items-in-cart", text: "11")
			expect(page).not_to have_content('Home Program')
			expect(page).to have_content('7.314.901,0 (IVA Incluído)')
		end

		it 'add mandatory products', js: true do 
			create(:cart_with_product_next_level)
			mandatory = create(:mandatory_product_ins)
			ins = create(:instalation, product: Product.first)
			create(:mandatory_product, instalation: ins, product: mandatory)
			visit cart_path
			expect(page).to have_current_path(cart_path)
			first('.collapsed').click
			sleep(1)
			first('#add-mandatory-'+CartItem.first.id.to_s).click
			wait_for_ajax
			expect(page).to have_content('Producto mandatorio agregado con éxito.')
			expect(page).to have_content('Tabla de conexión 123')
			expect(page).to have_content('7.363.256,0 (IVA Incluído)')
		end

		it 'add mandatory products and after delete parent', js: true do 
			create(:cart_with_product_next_level)
			mandatory = create(:mandatory_product_ins)
			ins = create(:instalation, product: Product.first)
			create(:mandatory_product, instalation: ins, product: mandatory)
			visit cart_path
			expect(page).to have_current_path(cart_path)
			first('.collapsed').click
			sleep(1)
			first('#add-mandatory-'+CartItem.first.id.to_s).click
			wait_for_ajax
			expect(page).to have_content('Producto mandatorio agregado con éxito.')
			expect(page).to have_content('Tabla de conexión 123')
			expect(page).to have_content('7.363.256,0 (IVA Incluído)')

			first('.remove-'+CartItem.first.id.to_s).click
			click_button('Eliminar')
			wait_for_ajax
			sleep(1)
			expect(page).to have_content('Producto eliminado con éxito')
			expect(page).to have_content('Aún no tienes productos asociados a tu cotización')
		end

		it 'add pipe mandatory', js: true do 
			create(:cart_with_product_next_level)
			create(:pre_visit_product)
			mandatory = create(:pipes)
			ins = create(:instalation, product: Product.first)
			create(:mandatory_product, instalation: ins, product: mandatory)
			visit cart_path
			expect(page).to have_current_path(cart_path)
			first('.collapsed').click
			sleep(1)
			first('#add-mandatory-'+CartItem.first.id.to_s).click
			wait_for_ajax
			sleep(1)
			expect(page).to have_content('Producto mandatorio agregado con éxito. Visita requerida para cotizar ductos.')
			expect(page).to have_content('Ductos')
			expect(page).to have_content('Pre-visita (IVA incluido)')
			expect(page).to have_content('7.344.801,0 (IVA Incluído)')
		end

		it 'try quotation without products', js: true do
			visit new_quotation_path
			expect(page).to have_current_path(cart_path)
			expect(page).to have_content('No hay productos para cotizar')
		end
	end
end