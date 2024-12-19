class QuotationMailerPreview < ActionMailer::Preview
	def change_state
		QuotationMailer.change_state(Quotation.first)
	end

	def change_state_for_miele
		QuotationMailer.change_state(Quotation.first, true)
	end

	def instalation_reminder
		QuotationMailer.instalation_reminder([Quotation.first.id])
	end

	def reject_quotation
		QuotationMailer.reject_quotation(Quotation.last)
	end
end