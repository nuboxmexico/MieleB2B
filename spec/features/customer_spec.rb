require 'rails_helper'
describe 'Customer', type: :feature do 

	context 'Cronjob' do
		before do 
			Rake::Task.define_task(:environment)
		end

		after do 
			Rake.application.clear
		end

		it 'clear linked partners' do 
			mca_user = create(:mca_user)
			create(:customer, user: mca_user, expiration_date: Date.today)
			
			load Rails.root.join("lib/tasks/check_customers_link.rake")
			task = Rake::Task["check_customers_link"]

			expect{task.invoke}.to output(/Proceso completado con éxito!/).to_stdout
			expect(Customer.last.user).to eq nil
			expect(Customer.last.expiration_date).to eq nil
		end

		it 'clear partners when link not expired' do 
			mca_user = create(:mca_user)
			create(:customer, user: mca_user, expiration_date: (Date.today - 1.days))
			
			load Rails.root.join("lib/tasks/check_customers_link.rake")
			task = Rake::Task["check_customers_link"]

			expect{task.invoke}.to output(/Proceso completado con éxito!/).to_stdout
			expect(Customer.last.user).not_to eq nil
			expect(Customer.last.expiration_date).not_to eq nil
		end
	end

	context 'Visit' do 
		it 'and search quotation', js: true do 
			quotation = create(:quotation_retirement)
			visit search_tracking_path
			expect(page).to have_current_path(search_tracking_path)
			fill_in 'rut', with: '111111111'
			fill_in 'code', with: quotation.code
			click_button('Buscar')
			expect(page).to have_content(quotation.customer_name)
			expect(page).to have_content(quotation.email)
			expect(page).to have_content(quotation.phone)
			expect(page).to have_content(quotation.user.email)
			expect(page).to have_content('$ 699.990')
		end

		it 'and search quotation that doesnt exists', js: true do 
			quotation = create(:quotation_retirement)
			visit search_tracking_path
			expect(page).to have_current_path(search_tracking_path)
			fill_in 'rut', with: '111111111'
			fill_in 'code', with: 'asdasdas'
			click_button('Buscar')
			expect(page).to have_current_path(search_tracking_path)
			expect(page).to have_content('La cotización que estás buscando no existe.')
		end
	end
end