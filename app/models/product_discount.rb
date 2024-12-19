class ProductDiscount < ApplicationRecord
	belongs_to :product
	has_many :discount_sale_channels, dependent: :destroy
	has_many :sale_channels, through: :discount_sale_channels

	def self.load_discounts(file)
		if !(spreadsheet = User.open_spreadsheet(file))
			return false, [-2]
		end
		headers = []
		spreadsheet.row(1).each_with_index {|header,i| headers.push(header) }
		if !headers.include? 'TNR' or !headers.include? 'Descuento' or !headers.include? 'Canal' or !headers.include? 'Fecha Inicio' or !headers.include? 'Fecha Término'
			return false, [-1]
		else
			file_errors = []
			i = 0
			spreadsheet.each(sku: 'TNR', discount: 'Descuento', area: 'Canal', start: 'Fecha Inicio', end: 'Fecha Término') do |row|
				if i > 0
					begin 
						sku_t = (row[:sku].kind_of?(String) ? row[:sku] : row[:sku].to_i.to_s)
						if (product_t = Product.find_by(sku: sku_t, ean: nil))
							if (discount_t = ProductDiscount.find_by(product: product_t)) and (row[:discount] == 0)
								discount_t.destroy!
							else
								if discount_t
									discount_t.update!(discount: row[:discount], start_date: Date.parse(row[:start]), end_date: Date.parse(row[:end]))
								else
									discount_t = ProductDiscount.create!(discount: row[:discount], start_date: Date.parse(row[:start]), end_date: Date.parse(row[:end]), product: product_t)
								end
								discount_t.sale_channels.destroy_all
								if !row[:area] or row[:area].empty?
									SaleChannel.all.map{|sale| discount_t.sale_channels << sale }
								else
									discount_t.sale_channels << SaleChannel.where(name: row[:area].split(','))
								end
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
