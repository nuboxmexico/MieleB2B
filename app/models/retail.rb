class Retail < ApplicationRecord
	has_many :retail_products, dependent: :destroy
	has_many :products, through: :retail_products
	has_many :quotations

	def self.load_tnr_retail(file)
		if !(spreadsheet = User.open_spreadsheet(file))
			return false, [-2]
		end
		headers = []
		spreadsheet.row(1).each_with_index {|header,i| headers.push(header) }
		if !headers.include? 'TNR Miele' or 
			!headers.include? 'Travel' or 
			!headers.include? 'KITCHENCENTER' or
			!headers.include? 'Paris Marketplace' or
			!headers.include? 'Mercado Libre' or
			!headers.include? 'Falabella Marketplace' or
			!headers.include? 'Ripley Marketplace' or
			!headers.include? 'Verde Olivo'
			return false, [-1]
		else
			file_errors = []
			i = 0
			retails = spreadsheet.row(1).drop(2).map do |retail|
				Retail.find_by(name: retail)
			end
			spreadsheet.each do |row|
				if i > 0
					begin
						sku_t = (row[0].kind_of?(String) ? row[0] : row[0].to_i.to_s)
						if product_t = Product.find_by(sku: sku_t, ean: nil)
							row = row.drop(2)
							retails.each_with_index do |retail, i|
								retail_product_t = RetailProduct.find_or_create_by(product: product_t, retail: retail)
								retail_product_t.update(tnr: row[i])
							end
						else
							file_errors.push(i+1)
						end
					rescue Exception => e 
						file_errors.push(i+1)
					end
				end
				i += 1
			end
		end
		return true, file_errors
	end
end
