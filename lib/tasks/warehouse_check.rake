desc 'Checkeo de cotizaciones que pasaron tiempo de bodegaje'
task warehouse_check: :environment do
	QuotationTask.warehouse_check
	puts 'Proceso completado con éxito!'
end