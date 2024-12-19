desc 'Checkeo de vínculos de clientes con vendedores'
task check_customers_link: :environment do
	Customer.check_expiration_partner
	puts 'Proceso completado con éxito!'
end