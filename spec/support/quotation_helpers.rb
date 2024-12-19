module QuotationHelpers
	def fill_form
		fill_in 'quotation_name', with: 'Prueba'
		fill_in 'quotation_lastname', with: 'proyecto'
		fill_in 'quotation_second_lastname', with: 'macanudo'
		fill_in 'quotation_email', with: 'prueba@chile.net'
		fill_in 'quotation_rut', with: '186746430'
		fill_in 'quotation_phone', with: '987654321'
		fill_in 'quotation_mobile_phone', with: '123456789'
		fill_in 'quotation_dispatch_address', with: 'Calle falsa'
		fill_in 'quotation_dispatch_address_number', with: '123'
		fill_in 'quotation_dispatch_dpto_number', with: '1116'
		within '#dispatch-commune-content' do
			find('.select2-container').click
		end
		find(".select2-search__field").set('Santiago')

		within ".select2-results__options" do
			find('li', text: 'Santiago').click
		end

		page.execute_script("$('#quotation_dispatch_commune_id').trigger('change');")
		wait_for_ajax

		fill_in 'quotation_personal_address', with: 'Calle verdadera'
		fill_in 'quotation_personal_address_number', with: '456'
		fill_in 'quotation_personal_dpto_number', with: '1532'

		within '#personal-commune-content' do
			find('.select2-container').click
		end
		find(".select2-search__field").set('Providencia')

		within ".select2-results__options" do
			find('li', text: 'Providencia').click
		end
		page.execute_script("$('#quotation_estimated_dispatch_date').val('25/12/2020')")
		page.execute_script("$('#quotation_installation_date').val('30/12/2020')")
		fill_in 'quotation_observations', with: 'Entregar solo horario AM'
	end
end
