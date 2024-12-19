class CustomRole < ApplicationRecord
	belongs_to :role
	belongs_to :sale_channel
	belongs_to :cost_center
	belongs_to :user

	validates :role_id, presence: { message: "no puede estar en vacío"}
	validates :cost_center_id, presence: { message: "no puede estar en vacío"}

	after_create :check_channel

	def manager?
		return self.role.try(:name) == 'Manager'
	end

	def seller?
		return self.role.try(:name) == 'Seller'
	end

	private

	def check_channel
		if !Role.where(name: ["Seller", "Manager"]).pluck(:id).include?(self.role_id)
			self.update!(sale_channel_id: nil)
		end
	end
end
