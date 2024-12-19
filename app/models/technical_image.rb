class TechnicalImage < ApplicationRecord
	belongs_to :product
	has_attached_file :image
	validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

	def self.upload_technical_images(files)
		files.each do |file|
			extn = File.extname file.original_filename  
			name_file = File.basename file.original_filename, extn
			sku_p = name_file.split("_")[0]
			product = Product.find_by(sku: sku_p, ean: nil)
			if product
				product.technical_images.create!(:image => file)
				product.save!
			end
		end
		return true
	end
end
