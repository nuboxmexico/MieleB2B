desc 'Checkeo de indicadores monetarios'
task check_indicators: :environment do
	Indicator.update_indicators
	puts 'Proceso completado con éxito!'
end