class ComparableAttribute < ApplicationRecord
	has_many :product_attributes, dependent: :destroy
	has_many :products, through: :product_attributes


	def self.load_comparator_info(file)
		unless (spreadsheet = User.open_spreadsheet(file))
			return false, [-2]
		end
		file_errors = []
		spreadsheet.each_with_pagename do |name, sheet|
			attributes = []
			sheet.row(1).drop(2).each do |attribute|
				comparable_attribute = ComparableAttribute.find_by(name: attribute)
				unless comparable_attribute
					comparable_attribute = ComparableAttribute.create(name: attribute)
				end
				attributes << comparable_attribute
			end
			i = 0
			sheet.each do |row|
				begin
					if i > 0
						sku = row.shift
						sku = sku.to_i.to_s if sku.class != String
						row.shift
						product = Product.find_by(sku: sku)
						if product
							attributes.each_with_index do |attribute, i|
								attr_aux = product.comparable_attributes.find_by(name: attribute.name)
								if attr_aux
									product.product_attributes
									.find_by(comparable_attribute: attr_aux)
									.update(value: row[i])
								else
									ProductAttribute.create(product: product,
										comparable_attribute: attribute,
										value: row[i])
								end
							end
						else
							file_errors.push(i+1)
						end
					end
				rescue Exception => e
					file_errors.push(i+1)
				end
				i += 1
			end
		end
		return true, file_errors
	end
end
