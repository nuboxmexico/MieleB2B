class CommissionParameter < ApplicationRecord
	def self.upload_commissions_parameters(file)
		if !(spreadsheet = User.open_spreadsheet(file))
			return false, [-2]
		end
		headers = []
		spreadsheet.row(2).each_with_index {|header,i| headers.push(header) }
		headers_required = ['Límite Inferior', 'Límite Superior', 'A', 'B', 'C', 'D', 'E']
		if !headers_required.all? { |e| headers.include?(e) }
			return false, [-1]
		else
			file_errors = []
			i = 0
			CommissionParameter.destroy_all
			spreadsheet.each(lower_bound: 'Límite Inferior', upper_bound: 'Límite Superior', level_a: 'A', level_b: 'B', level_c: 'C', level_d: 'D', level_e: 'E') do |row|
				if i > 0
					begin
						if (com_t = CommissionParameter.last)
							if ((com_t.upper_bound + 1) == row[:lower_bound].to_i) and (row[:lower_bound].to_i < row[:upper_bound].to_i) and row[:level_a].to_i <= 100 and row[:level_b].to_i <= 100 and row[:level_c].to_i <= 100 and row[:level_d].to_i <= 100 and row[:level_e].to_i <= 100
								CommissionParameter.create(row)
							else
								file_errors.push(i+1)
								CommissionParameter.destroy_all
								return true, file_errors
							end
						elsif (row[:lower_bound].to_i < row[:upper_bound].to_i) and row[:level_a].to_i <= 100 and row[:level_b].to_i <= 100 and row[:level_c].to_i <= 100 and row[:level_d].to_i <= 100 and row[:level_e].to_i <= 100
							CommissionParameter.create(row)
						else
							file_errors.push(i+1)
							CommissionParameter.destroy_all
							return true, file_errors
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
