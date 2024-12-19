desc 'Update product core ids'
task update_product_core_ids: :environment do
	Product.where(core_id: nil).each do |product|
		if product.update_core_id
			puts "Core id de #{product.sku} actualizado exitosamente."
		else
			puts "Core id de #{product.sku} no se ha actualizado. Registrelo antes."
		end
	end
	puts 'Proceso completado con éxito!'
end