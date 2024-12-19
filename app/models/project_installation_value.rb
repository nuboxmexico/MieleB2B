class ProjectInstallationValue < ApplicationRecord


    def self.upload_project_installation_value(file)
		if !(spreadsheet = User.open_spreadsheet(file))
			return false, [-2]
		end
		headers = []
		spreadsheet.row(1).each_with_index {|header,i| headers.push(header) }
		headers_required = ['Rango inicial n° equipos en una misma unidad inmobiliaria (casa, departamento o villa)', 'Rango final n° equipos en una misma unidad inmobiliaria (casa, departamento o villa)', 'Costo por Equipo CLP$ (Neto) RM','Costo adicional en regiones CLP$ (Neto)']
		if !headers_required.all? { |e| headers.include?(e) }
			return false, [-1]
		else
			ProjectInstallationValue.delete_all
			file_errors = []
			i = 0
			spreadsheet.each(min_amount: 'Rango inicial n° equipos en una misma unidad inmobiliaria (casa, departamento o villa)', max_amount: 'Rango final n° equipos en una misma unidad inmobiliaria (casa, departamento o villa)', cost_RM: 'Costo por Equipo CLP$ (Neto) RM', cost_additional_region: 'Costo adicional en regiones CLP$ (Neto)') do |row|
				if i > 0
					begin
						project_installation_value = ProjectInstallationValue.create(min_amount: row[:min_amount].to_i, max_amount: row[:max_amount].to_i, cost_RM: row[:cost_RM].to_f, cost_additional_region: row[:cost_additional_region].to_f)
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