require 'rails_helper'
describe 'Comparator', type: :feature do 
	let(:user)                   {create(:user)}

	context 'Use' do
		before do 
			login_as(user, scope: :user)
			#create(:product_comparable_2)
		end
		it 'try to visit empty comparator', js: true do
			visit comparator_path
			expect(page).to have_current_path(comparator_path)
			expect(page).to have_content('¡No tienes suficientes productos para comparar!')
			expect(Comparator.last.products.size).to eq 0
			click_link('Volver')
			expect(page).to have_current_path(business_units_path)
		end

		it 'add product to comparator', js: true do 
			create(:product_comparable_1)
			visit products_path(business_unit: 'Cocción')
			expect(page).to have_current_path(products_path(business_unit: 'Cocción'))
			first('.checkbox').click
			wait_for_ajax
			expect(page).to have_content('Tienes productos seleccionados para comparar')
			expect(page).to have_content('Producto agregado al comparador')
			expect(Comparator.last.products.size).to eq 1
		end

		it 'add product to comparator and empty', js: true do 
			create(:product_comparable_1)
			visit products_path(business_unit: 'Cocción')
			expect(page).to have_current_path(products_path(business_unit: 'Cocción'))
			first('.checkbox').click
			wait_for_ajax
			expect(page).to have_content('Tienes productos seleccionados para comparar')
			expect(page).to have_content('Producto agregado al comparador')
			expect(Comparator.last.products.size).to eq 1
			first('.fa-times').click
			wait_for_ajax
			sleep(1)
			expect(page).to have_content('Se borró la actual selección de productos a comparar')
		end

		it 'try to compare only 1 product', js: true do 
			create(:product_comparable_1)
			visit products_path(business_unit: 'Cocción')
			expect(page).to have_current_path(products_path(business_unit: 'Cocción'))
			first('.checkbox').click
			wait_for_ajax
			expect(page).to have_content('Tienes productos seleccionados para comparar')
			expect(page).to have_content('Producto agregado al comparador')
			expect(Comparator.last.products.size).to eq 1
			visit comparator_path
			expect(page).to have_current_path(comparator_path)
			expect(page).to have_content('¡No tienes suficientes productos para comparar!')
		end

		it 'add and remove 1 product', js: true do
			create(:product_comparable_1)
			visit products_path(business_unit: 'Cocción')
			expect(page).to have_current_path(products_path(business_unit: 'Cocción'))
			first('.checkbox').click
			wait_for_ajax
			expect(page).to have_content('Tienes productos seleccionados para comparar')
			expect(page).to have_content('Producto agregado al comparador')
			expect(Comparator.last.products.size).to eq 1

			first('.checkbox').click
			wait_for_ajax
			sleep(1)
			expect(Comparator.last.products.size).to eq 0
		end

		it 'compare 2 products', js: true do 
			prod_1 = create(:product_comparable_1)
			prod_2 = create(:product_comparable_2)
			visit products_path(business_unit: 'Cocción')
			expect(page).to have_current_path(products_path(business_unit: 'Cocción'))
			first('.checkbox'+prod_1.id.to_s).click
			wait_for_ajax
			expect(page).to have_content('Tienes productos seleccionados para comparar')
			expect(page).to have_content('Producto agregado al comparador')
			expect(Comparator.last.products.size).to eq 1
			first('.checkbox'+prod_2.id.to_s).click
			wait_for_ajax
			expect(Comparator.last.products.size).to eq 2
			expect(page).to have_content('Producto agregado al comparador')
			visit comparator_path
			expect(page).to have_current_path(comparator_path)
			expect(all('.product-box').length).to be 2
			expect(page).to have_content(prod_1.name)
			expect(page).to have_content(prod_2.name)
			click_link('Volver')
			expect(Comparator.last.products.size).to eq 0
			expect(page).to have_current_path(products_path(business_unit: 'Cocción'))
		end

		it 'try to compare 4 products', js: true do 
			prod_1 = create(:product_comparable_1)
			prod_2 = create(:product_comparable_2)
			prod_3 = create(:product_comparable_3)
			prod_4 = create(:product_comparable_4)
			visit products_path(business_unit: 'Cocción')
			expect(page).to have_current_path(products_path(business_unit: 'Cocción'))
			first('.checkbox'+prod_1.id.to_s).click
			wait_for_ajax
			expect(page).to have_content('Tienes productos seleccionados para comparar')
			expect(page).to have_content('Producto agregado al comparador')
			expect(Comparator.last.products.size).to eq 1
			first('.checkbox'+prod_2.id.to_s).click
			wait_for_ajax
			expect(page).to have_content('Producto agregado al comparador')
			expect(Comparator.last.products.size).to eq 2
			first('.checkbox'+prod_3.id.to_s).click
			wait_for_ajax
			expect(page).to have_content('Producto agregado al comparador')
			expect(Comparator.last.products.size).to eq 3
			first('.checkbox'+prod_4.id.to_s).click
			wait_for_ajax
			expect(Comparator.last.products.size).to eq 3
			expect(page).to have_content('Haz alcanzado el límite de productos en el comparador')
		end

		it 'login for comparate and logout', js: true do
			prod_1 = create(:product_comparable_1)
			visit products_path(business_unit: 'Cocción')
			expect(page).to have_current_path(products_path(business_unit: 'Cocción'))
			first('.checkbox'+prod_1.id.to_s).click
			wait_for_ajax
			expect(page).to have_content('Tienes productos seleccionados para comparar')
			expect(page).to have_content('Producto agregado al comparador')

			first('.sidebar-toggle').click
			first('.sign-out', visible: false).click
			expect(page).to have_current_path(new_user_session_path)
			fill_in 'user_email', with: 'oferusat@gmail.com'
			fill_in 'user_password', with: '123456'
			find('input[type="submit"]').click
			expect(page).to have_current_path(root_path)
			expect(Comparator.last.products.size).to eq 0
		end

		it 'try to compare products from diferent families', js: true do 
			prod_1 = create(:product_comparable_1)
			prod_2 = create(:product_comparable_2_different)
			prod_2.families << Family.first
			visit products_path(business_unit: 'Cocción')
			expect(page).to have_current_path(products_path(business_unit: 'Cocción'))
			first('.checkbox'+prod_1.id.to_s).click
			wait_for_ajax
			expect(page).to have_content('Tienes productos seleccionados para comparar')
			expect(page).to have_content('Producto agregado al comparador')
			expect(Comparator.last.products.size).to eq 1
			first('.checkbox'+prod_2.id.to_s).click
			wait_for_ajax
			expect(Comparator.last.products.size).to eq 1
			expect(page).to have_content('El producto que intentas agregar no pertenece a la misma familia del comparador.')
		end

		it 'compare 2 products, one with offer', js: true do 
			Timecop.freeze(Date.new(2020, 04, 01))
			prod_1 = create(:product_comparable_1)
			prod_2 = create(:product_comparable_2)
			create(:product_discount, product: prod_1)
			visit products_path(business_unit: 'Cocción')
			expect(page).to have_current_path(products_path(business_unit: 'Cocción'))
			first('.checkbox'+prod_1.id.to_s).click
			wait_for_ajax
			expect(page).to have_content('Tienes productos seleccionados para comparar')
			expect(page).to have_content('Producto agregado al comparador')
			expect(Comparator.last.products.size).to eq 1
			first('.checkbox'+prod_2.id.to_s).click
			wait_for_ajax
			expect(Comparator.last.products.size).to eq 2
			expect(page).to have_content('Producto agregado al comparador')
			visit comparator_path
			expect(page).to have_current_path(comparator_path)
			expect(all('.product-box').length).to be 2
			expect(page).to have_content(prod_1.name)
			expect(page).to have_content(prod_2.name)
			expect(page).to have_content('$ 559.992')
			Timecop.return
		end
	end
end