desc 'Checkeo de cotizaciones pendientes de pago'
task check_pending_quotations: :environment do
	QuotationTask.check_pending
	puts 'Proceso completado con éxito!'
end