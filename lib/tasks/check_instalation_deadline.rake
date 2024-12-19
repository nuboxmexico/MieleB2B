desc 'Checkeo de cotizaciones por instalar'
task check_instalation_deadline: :environment do
	QuotationTask.instalation_reminder
	puts 'Proceso completado con éxito!'
end

