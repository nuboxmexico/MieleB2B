class Banner < ApplicationRecord
	has_attached_file :banner_image, styles: {medium: "600x300", thumbnail: "200x100" }
	validates_attachment_content_type :banner_image, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]

	has_attached_file :banner_mobile, styles: {medium: "600x300", thumbnail: "200x100" }
	validates_attachment_content_type :banner_mobile, :content_type => ["image/jpg", "image/jpeg", "image/png", "image/gif"]
end
