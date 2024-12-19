class Users::SessionsController < Devise::SessionsController
	after_action :empty_comparator, only: [:create]
	skip_before_action :check_role, only: :destroy
	private 

	def empty_comparator
		if comparator = Comparator.find_by(user: resource)
			comparator.comparator_products.destroy_all
		end
	end
end