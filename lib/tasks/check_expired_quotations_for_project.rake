desc 'Checkeo de cotizaciones de proyectos por vencer'
task check_expired_quotations_for_project: :environment do
	QuotationTask.check_expired_for_project
	puts 'Proceso completado con éxito!'
end