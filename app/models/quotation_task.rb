class QuotationTask
	def self.check_expired
		Quotation.joins(:quotation_state)
						 .where(expiration_date: Date.today, 
						 				quotation_states: {name: 'Enviada'})
						 .each do |quotation|
			quotation.to_state("Vencida")
			Product.reverse_stock(quotation.quotation_products) if (quotation.payments.completed.size > 0)
			MieleCoreApi.restore_stock_products_on_miele_core(@quotation.quotation_products) if (quotation.payments.completed.size > 0)
		end
	end

	def self.check_expired_for_project
		Quotation.joins(:quotation_state)
			.where( expiration_date: Date.today, 
					quotation_states: {name: 'En Negociación'} )
			.each do |quotation|
				quotation.to_state("Vencida")
				Product.reverse_stock(quotation.quotation_products) if (quotation.payments.completed.size > 0)
		end
	end

	def self.check_pending
		Quotation.where("quotations.estimated_dispatch_date - integer '14' = ? OR 
										 quotations.estimated_dispatch_date - integer '7' = ? OR 
										 quotations.estimated_dispatch_date - integer '3' = ?", 
										 Date.today, Date.today, Date.today)
						 .where('quotation_states.name = ?', "Pendiente")
						 .joins(:quotation_state)
						 .each do |quotation|
			QuotationMailer.change_state(quotation).deliver_later
		end
	end

	def self.check_for_expire
		Quotation.where(expiration_date: (Date.today+3.days)).joins(:quotation_state).where('quotation_states.name = ?', "Enviada").map{ |quotation| QuotationMailer.expire_reminder(quotation).deliver_later }
	end

	def self.instalation_reminder
		quotations = Quotation.joins(:quotation_state)
													.where('quotation_states.name = ?', "Por instalar")
													.where(installation_date: (Date.today + 5.days))
													.pluck('quotations.id')
		QuotationMailer.instalation_reminder(quotations).deliver_later if (quotations.any?)
	end

	def self.finance_reminder
		quotations = Quotation.joins(:quotation_state)
													.where('quotation_states.name = ?', "En preparación")
													.where(estimated_dispatch_date: (Date.today + 5.days))
													.pluck(:id)
		QuotationMailer.finance_reminder(quotations).deliver_later if (quotations.any?)
	end

	def self.warehouse_check
		Quotation.where(expiration_date: (Date.today-1.days)).joins(:quotation_state).where('quotation_states.name = ?', "En preparación").map{|quotation| QuotationMailer.warehouse_check(quotation, true).deliver_later}
		Quotation.where(expiration_date: Date.today).joins(:quotation_state).where('quotation_states.name = ?', "En preparación").map{|quotation| QuotationMailer.warehouse_check(quotation, false).deliver_later}
	end
end