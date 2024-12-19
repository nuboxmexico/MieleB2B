require 'rails_helper'
describe 'Dashboard', type: :feature do 
	let(:user){create(:user)}
	let(:mca_user){create(:mca_user)}
	let(:project_user){create(:project_user)}

	context 'Admin' do
		before do 
			login_as(user, scope: :user)
			create(:project_business_sale_channel)
			create(:sale_channel)
			create(:own_retail_sale_channel)
			create(:retail_sale_channel)
			create(:ecommerce_sale_channel)
			quotation_1 = create(:quotation_retirement, created_at: (DateTime.now - 1.days), sale_channel: SaleChannel.find_by(name: 'MCA'))
			quotation_2 = create(:quotation_retirement, sale_channel: SaleChannel.find_by(name: 'Proyectos'))
			quotation_2.update(progress_date: DateTime.now - 2.days)
			create(:productos_activados)
			quotation_2.to_state('Productos activados')
			quotation_3 = create(:quotation, sale_channel: SaleChannel.find_by(name: 'Own Retail'))
			quotation_3.update(progress_date: DateTime.now - 3.days)
			quotation_3.quotation_products << create(:quotation_product_2)
			create(:en_preparacion)
			quotation_3.to_state('En preparación')
			quotation_4 = create(:quotation, sale_channel: SaleChannel.find_by(name: 'Own Retail'))
			quotation_4.quotation_products << create(:quotation_product_3)
			create(:pendiente)
			create(:ecommerce_sale)
			quotation_4.to_state('Pendiente')
			quotation_1.update(total: quotation_1.total_calc)
			quotation_2.update(total: quotation_2.total_calc)
			quotation_3.update(total: quotation_3.total_calc)
			quotation_4.update(total: quotation_4.total_calc)
		end

		it 'view dashboard', js: true do 
			visit root_path
			expect(page).to have_current_path(root_path)
			expect(Dashboard.quotations_by_state(user)).to eq ({:categories=>["Proyectos", "MCA", "Own Retail", "Retail", "E-commerce"], :data=>[{:name=>"En Progreso", :data=>[1, 0, 1, 0, 1], :color=>"#D5243D"}, {:name=>"Creadas", :data=>[0, 1, 1, 0, 0], :color=>"#FD9184"}]})
			within '#quotations-state' do
				expect(page).to have_content('Cotizaciones Enviadas v/s Cerradas')
				expect(find('.highcharts-xaxis-labels')).to have_content('Proyectos MCA Own Retail Retail E-commerce')
				expect(find('.highcharts-yaxis')).to have_content('Cotizaciones')
				expect(page).to have_content('En Progreso Creadas')
			end
			within '#top-products' do 
				expect(page).to have_content('Máquina de Café CM5300')
				expect(page).to have_content('Cava de Vino Empotrable KWT 6112')
				expect(page).to have_content('Horno Multifunción H 2265 BP')
				expect(find('.highcharts-xaxis')).to have_content('Producto')
				expect(find('.highcharts-yaxis')).to have_content('Unidades')
				expect(page).to have_content('Cotizaciones En Progreso Cotizaciones Creadas')
			end
			expect(all('.panel').length).to be 4
			within '#chart-channels' do 
				expect(find('.highcharts-xaxis-labels')).to have_content('Proyectos MCA Own Retail Retail E-commerce')
				expect(find('.highcharts-yaxis')).to have_content('Monto $')
				expect(page).to have_content('$ 4 279 980')
			end
		end

		it 'filter by date', js: true do 
			visit root_path
			expect(page).to have_current_path(root_path)
			fill_in 'date_range', with: "#{(Date.today-1.days).strftime("%d/%m/%Y")} - #{(Date.today).strftime("%d/%m/%Y")}"
			click_button('Guardar')
			wait_for_ajax
			expect(page).to have_css('#quotations-state')
			expect(page).to have_css('#chart-channels')
			expect(page).to have_css('#top-products')
			expect(Dashboard.quotations_per_channel(user, (DateTime.now - 3.days).beginning_of_day, DateTime.now.end_of_day)).to eq ({:data=>{:name=>"Canales de Venta", :colorByPoint=>true, :data=>[{:name=>"Proyectos", :y=>699990, :color=>"#F59B00", :drilldown=>"Proyectos"}, {:name=>"MCA", :y=>0, :color=>"#F59B00", :drilldown=>"MCA"}, {:name=>"Own Retail", :y=>4279980, :color=>"#8C0314", :drilldown=>"Own Retail"}, {:name=>"Retail", :y=>0, :color=>"#FD9184", :drilldown=>"Retail"}, {:name=>"E-commerce", :y=>10000, :color=>"#D5423D", :drilldown=>"E-commerce"}]}, :drilldown=>{:series=>[{:name=>"Proyectos", :id=>"Proyectos", :data=>[["Web Shop", 699990]]}, {:name=>"MCA", :id=>"MCA", :data=>[]}, {:name=>"Own Retail", :id=>"Own Retail", :data=>[["Web Shop", 4279980]]}, {:name=>"Retail", :id=>"Retail", :data=>[]}, {:name=>"E-commerce", :id=>"E-commerce", :data=>[]}]}})
		end
	end

	context 'Manager' do
		before do 
			login_as(mca_user, scope: :user)
			create(:project_business_sale_channel)
			create(:own_retail_sale_channel)
			create(:retail_sale_channel)
			create(:ecommerce_sale_channel)
			quotation_1 = create(:quotation_retirement, sale_channel: SaleChannel.find_by(name: 'Own Retail'))
			quotation_2 = create(:quotation_retirement, sale_channel: SaleChannel.find_by(name: 'Proyectos'))
			create(:productos_activados)
			quotation_2.to_state('Productos activados')
			quotation_3 = create(:quotation, sale_channel: SaleChannel.find_by(name: 'MCA'))
			create(:en_preparacion)
			quotation_3.to_state('En preparación')
			quotation_3.update(progress_date: Date.today)
			quotation_4 = create(:quotation, sale_channel: SaleChannel.find_by(name: 'MCA'))
			create(:pendiente)
			quotation_4.to_state('Pendiente')
			quotation_3.quotation_products << create(:quotation_product_2)
			quotation_4.quotation_products << create(:quotation_product_3)
			quotation_1.update(total: quotation_1.total_calc)
			quotation_2.update(total: quotation_2.total_calc)
			quotation_3.update(total: quotation_3.total_calc)
			quotation_4.update(total: quotation_4.total_calc)
			SaleChannel.find_by(name: 'MCA').products << Product.find_by(name: 'Horno Multifunción H 2265 BP')
			SaleChannel.find_by(name: 'MCA').products << Product.find_by(name: 'Cava de Vino Empotrable KWT 6112')
		end

		it 'view dashboard', js: true do 
			visit root_path
			expect(page).to have_current_path(root_path)
			expect(Dashboard.quotations_by_state(mca_user)).to eq ({:categories=>["MCA"], :data=>[{:name=>"En Progreso", :data=>[1], :color=>"#D5243D"}, {:name=>"Creadas", :data=>[1], :color=>"#FD9184"}]})
			within '#quotations-state' do
				expect(page).to have_content('Cotizaciones Enviadas v/s Cerradas')
				expect(find('.highcharts-xaxis-labels')).to have_content('MCA')
				expect(find('.highcharts-yaxis')).to have_content('Cotizaciones')
				expect(page).to have_content('En Progreso Creadas')
			end
			within '#top-products' do 
				expect(page).not_to have_content('Máquina de Café CM5300')
				expect(page).to have_content('Cava de Vino Empotrable KWT 6112')
				expect(page).to have_content('Horno Multifunción H 2265 BP')
				expect(find('.highcharts-xaxis')).to have_content('Producto')
				expect(find('.highcharts-yaxis')).to have_content('Unidades')
				expect(page).to have_content('Cotizaciones En Progreso Cotizaciones Creadas')
			end
			expect(all('.panel').length).to be 2
			within '#chart-channels' do 
				expect(find('.highcharts-xaxis-labels')).to have_content('MCA')
				expect(find('.highcharts-yaxis')).to have_content('Monto $')
				expect(page).to have_content('$ 4 279 980')
				first('.highcharts-drilldown-axis-label').click
				sleep(1)
				expect(page).to have_content('Web Shop')
				expect(page).to have_content('$ 4.279.980')
			end
		end

		it 'filter by date', js: true do 
			visit root_path
			expect(page).to have_current_path(root_path)
			fill_in 'date_range', with: "#{(Date.today-1.days).strftime("%d/%m/%Y")} - #{(Date.today).strftime("%d/%m/%Y")}"
			click_button('Guardar')
			wait_for_ajax
			expect(page).to have_css('#quotations-state')
			expect(page).to have_css('#chart-channels')
			expect(page).to have_css('#top-products')
			expect(Dashboard.products_most_selled(mca_user, (Date.today - 1.days), Date.today)).to eq ({:categories=>[], :data=>[{:name=>"Cotizaciones En Progreso", :data=>[], :color=>"#D5243D"}, {:name=>"Cotizaciones Creadas", :data=>[], :color=>"#FD9184"}]})
		end
	end
end