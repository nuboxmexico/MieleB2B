desc 'Checkeo de cotizaciones por vencer'
task check_for_expire: :environment do
	QuotationTask.check_for_expire
	puts 'Proceso completado con éxito!'
end
