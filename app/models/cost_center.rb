class CostCenter < ApplicationRecord
	acts_as_paranoid
	has_many :quotations
	has_many :users
	has_many :products, -> { with_deleted }

	def self.upload_cost_centers(file)
		if !(spreadsheet = User.open_spreadsheet(file))
			return false, [-2]
		end
		headers = []
		spreadsheet.row(1).each_with_index {|header,i| headers.push(header) }
		headers_required = ['ID', 'CostCentre', 'Borrar']
		if !headers_required.all? { |e| headers.include?(e) }
			return false, [-1]
		else
			file_errors = []
			i = 0
			spreadsheet.each(code: 'ID', name: 'CostCentre', delete: 'Borrar') do |row|
				if i > 0
					begin
						cost_center = CostCenter.find_or_create_by(code: row[:code])
						(row[:delete].try(:downcase) == 'si') ? cost_center.destroy : cost_center.update(name: row[:name])
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
