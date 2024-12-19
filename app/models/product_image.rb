class ProductImage < ApplicationRecord
	default_scope{ order("image_file_name ASC") }
	belongs_to :product
	has_attached_file :image
	validates_attachment_content_type :image, content_type: /\Aimage\/.*\z/

	def self.upload_images(files)
		updated = 0
		files.each do |file|
			extn = File.extname file.original_filename  
			name_file = File.basename file.original_filename, extn
			name_file = name_file.split("_")
			sku_p = name_file[0]
			if (product = Product.find_by(sku: sku_p, ean: nil)) and (image_t = ProductImage.find_by(image_file_name: file.original_filename))
				image_t.update(:image => file)
				updated += 1
			elsif product
				product.images.create!(:image => file)
				product.save!
			end
		end
		return updated, true
	end
end
