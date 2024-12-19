class ProjectInstallationDiscount < ApplicationRecord
    
    
    def self.upload_project_installation_discount(file)
		if !(spreadsheet = User.open_spreadsheet(file))
			return false, [-2]
		end
		headers = []
		spreadsheet.row(1).each_with_index {|header,i| headers.push(header) }
		headers_required = ['Rango inicial valor del Proyecto', 'Rango final valor del Proyecto', 'Porcentaje de descuento sobre tarifas de instalación']
		if !headers_required.all? { |e| headers.include?(e) }
			return false, [-1]
		else
			ProjectInstallationDiscount.delete_all
			file_errors = []
			i = 0
			spreadsheet.each(min_amount: 'Rango inicial valor del Proyecto', max_amount: 'Rango final valor del Proyecto', discount_percentage: 'Porcentaje de descuento sobre tarifas de instalación') do |row|
				if i > 0
					begin
						project_installation_discount = ProjectInstallationDiscount.create(min_amount: row[:min_amount].to_i, max_amount: row[:max_amount].to_i, discount_percentage: row[:discount_percentage].to_f)
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
