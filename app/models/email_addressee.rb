class EmailAddressee < ApplicationRecord
  acts_as_paranoid
  belongs_to :user
  validates :process, inclusion: { in: ['En curso', 'En preparación', 'En preparación con instalación', 'Instalación', 'Despacho', 'Marketing', 'Nuevo pago', 'Manager Proyectos'],
    message: "%{value} is not a valid process" }
  

  def self.load_addressees(file)
		if !(spreadsheet = User.open_spreadsheet(file))
			return false, [-2]
		end
		headers = []
		spreadsheet.row(1).each_with_index {|header,i| headers.push(header) }
		headers_required = ['Proceso','Correo']
		if !headers_required.all? { |e| headers.include?(e) }
			return false, [-1]
		else
			EmailAddressee.destroy_all
			file_errors = []
			i = 0
			spreadsheet.each(process: 'Proceso', email: 'Correo') do |row|
				if i > 0
					begin
						user = User.find_by_email!(row[:email].strip)
						EmailAddressee.create!(user: user, process:row[:process].strip)
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
