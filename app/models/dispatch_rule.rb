class DispatchRule < ApplicationRecord

    def self.upload_dispatch_rule(file)
		if !(spreadsheet = User.open_spreadsheet(file))
			return false, [-2]
		end
		headers = []
		spreadsheet.row(1).each_with_index {|header,i| headers.push(header) }
		headers_required = ['Destino', 'Rango inicial de equipos', 'Rango final de equipos', 'MDA', 'SDA', 'PAI']
		if !headers_required.all? { |e| headers.include?(e) }
			return false, [-1]
		else
			DispatchRule.delete_all
			file_errors = []
			i = 0
			spreadsheet.each(region_name: 'Destino', min_amount: 'Rango inicial de equipos', max_amount: 'Rango final de equipos', mda: 'MDA', sda: 'SDA', pai: 'PAI') do |row|
				if i > 0
					begin
						dispatch_rule = DispatchRule.create(region_name: row[:region_name] , min_amount: row[:min_amount].to_i, max_amount: row[:max_amount].to_i, mda: row[:mda].to_i, sda: row[:sda].to_i, pai: row[:pai].to_i)
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
