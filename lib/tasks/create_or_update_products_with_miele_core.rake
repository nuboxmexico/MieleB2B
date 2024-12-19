desc 'Se crean o actualizan productos con que se encuentren presentes en miele core'
task create_or_update_products_with_miele_core: :environment do
	RequestDataMieleCore.synchronizeProductsWithMieleCore
	puts 'Proceso completado con éxito!'
end