require 'rails_helper'
describe 'Banner', type: :feature do 
	let(:user)                   {create(:user)}

	context 'Administration' do
		before do 
			login_as(user, scope: :user)
		end

		it 'load banner', js: true do
			visit banners_path
			expect(page).to have_current_path(banners_path)
			expect(all('.banner-row').length).to be 0
			first('#new-banner').click
			expect(page).to have_current_path(new_banner_path)
			attach_file('banner-image-load', Rails.root + "spec/aux/banner_desktop.jpg", make_visible: true)
			attach_file('banner-mobile-load', Rails.root + "spec/aux/banner_mobile.jpg", make_visible: true)
			fill_in 'banner_url', with: 'https://www.google.cl'
			first('#submit-banner').click
			expect(page).to have_current_path(banners_path)
			expect(all('.banner-row').length).to be 1
			within first('.banner-row') do
				expect(page).to have_content('https://www.google.cl')
				expect(page).to have_content(Date.today.strftime("%d/%m/%Y"))
			end
			expect(Banner.all.size).to eq 1
			visit business_units_path
			expect(page).to have_current_path(business_units_path)
			expect(page.first('.img-responsive')['src']).to include('banner_desktop.jpg')
		end

		it 'download reference image', js: true do
			Capybara.current_driver = :webkit
			visit new_banner_path
			expect(page).to have_current_path(new_banner_path)
			first('#image-reference-template').click
			expect(page.response_headers['Content-Disposition']).to eq 'attachment; filename="referencia.jpg"'
			Capybara.use_default_driver
		end

		it 'load banner and delete', js: true do
			visit banners_path
			expect(page).to have_current_path(banners_path)
			expect(all('.banner-row').length).to be 0
			first('#new-banner').click
			expect(page).to have_current_path(new_banner_path)
			attach_file('banner-image-load', Rails.root + "spec/aux/banner_desktop.jpg", make_visible: true)
			attach_file('banner-mobile-load', Rails.root + "spec/aux/banner_mobile.jpg", make_visible: true)
			fill_in 'banner_url', with: 'https://www.google.cl'
			first('#submit-banner').click
			expect(page).to have_current_path(banners_path)
			expect(all('.banner-row').length).to be 1
			within first('.banner-row') do
				first('.miele-text').click
			end
			sleep(1)
			click_button('Eliminar')
			wait_for_ajax
			expect(all('.banner-row').length).to be 0
			expect(Banner.all.size).to eq 0
		end

		it 'load banner not valid', js: true do 
			Timecop.freeze(Date.new(2020, 04, 01))
			visit banners_path
			expect(page).to have_current_path(banners_path)
			expect(all('.banner-row').length).to be 0
			first('#new-banner').click
			expect(page).to have_current_path(new_banner_path)
			attach_file('banner-image-load', Rails.root + "spec/aux/banner_desktop.jpg", make_visible: true)
			attach_file('banner-mobile-load', Rails.root + "spec/aux/banner_mobile.jpg", make_visible: true)
			fill_in 'banner_url', with: 'https://www.google.cl'

			page.execute_script("$('#banner_start_date').val('01/03/2020')")
			page.execute_script("$('#banner_end_date').val('30/03/2020')")

			first('#submit-banner').click
			expect(page).to have_current_path(banners_path)
			expect(all('.banner-row').length).to be 1
			within first('.banner-row') do
				expect(page).to have_content('https://www.google.cl')
				expect(page).to have_content('01/03/2020')
				expect(page).to have_content('30/03/2020')
			end
			expect(Banner.all.size).to eq 1
			visit business_units_path
			expect(page).to have_current_path(business_units_path)
			expect(all('.item').length).to be 0
			Timecop.return
		end
	end
end