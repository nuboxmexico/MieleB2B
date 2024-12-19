desc 'Checkeo de cotizaciones por vencer'
task check_expired_quotations: :environment do
	QuotationTask.check_expired
	puts 'Proceso completado con éxito!'
end