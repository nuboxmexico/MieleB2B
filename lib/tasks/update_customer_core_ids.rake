desc 'Update customer core ids'
task update_customer_core_ids: :environment do
	Customer.where(core_id: nil).each do |customer|
		if customer.update_core_id
			puts "Core id de #{customer.email} actualizado exitosamente."
		else
			puts "Core id de #{customer.email} no se ha actualizado. Registrelo antes."
		end
	end
	puts 'Proceso completado con éxito!'
end