class MieleRole < ApplicationRecord
	acts_as_paranoid
	has_many :users, dependent: :nullify
	has_many :quotations, dependent: :nullify
	has_many  :referred_quotations, class_name: "Quotation", foreign_key: "partner_referred_id", dependent: :nullify
	has_many :selected_quotations, class_name: "Quotation", foreign_key: "partner_selected_commission_id"
	def self.upload_roles(file)
		if !(spreadsheet = User.open_spreadsheet(file))
			return false, [-2]
		end
		headers = []
		spreadsheet.row(1).each_with_index {|header,i| headers.push(header) }
		headers_required = ['ID', 'Nombre', 'Clasificación Socio Comercial', 'Borrar']
		if !headers_required.all? { |e| headers.include?(e) }
			return false, [-1]
		else
			file_errors = []
			i = 0
			spreadsheet.each(code: 'ID', name: 'Nombre', classification: 'Clasificación Socio Comercial', delete: 'Borrar') do |row|
				if i > 0
					begin
						code_t = (row[:code].kind_of?(String) ? row[:code] : row[:code].to_i.to_s)
						miele_role = MieleRole.find_or_create_by(code: code_t)
						if (row[:delete].try(:downcase) == 'si')
							miele_role.destroy
						else
							miele_role.update(name: row[:name], classification: row[:classification])
						end
					rescue Exception => e 
						file_errors.push(i+1)
					end
				end
				i+= 1
			end
		end
		return true, file_errors
	end
end