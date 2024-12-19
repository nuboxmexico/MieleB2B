json.array!(@customers) do |customer|
	json.extract! customer, :id, :rut, :name, :lastname, :second_lastname, :phone, :mobile_phone, :email, :personal_address, :personal_address_number, :personal_dpto_number, :personal_commune_id, :dispatch_address, :dispatch_address_number, :dispatch_dpto_number, :dispatch_commune_id, :instalation_address, :instalation_address_number, :instalation_dpto_number, :instalation_commune_id, :business_name, :business_sector, :business_rut, :billing_address, :billing_address_number, :billing_dpto_number, :billing_commune_id, :personal_address_street_type, :dispatch_address_street_type
	json.set! :fullname, customer.customer_name
	json.set! :linked_to, (customer.user ? "<div class='warning-msg'>RUT asociado a #{customer.user.try(:sale_channel).try(:name)}, #{customer.user.try(:fullname)}.</div>" : '')
end
