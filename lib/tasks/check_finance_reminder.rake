desc 'Checkeo de cotizaciones por despachar'
task check_finance_reminder: :environment do
	QuotationTask.finance_reminder
	puts 'Proceso completado con éxito!'
end
