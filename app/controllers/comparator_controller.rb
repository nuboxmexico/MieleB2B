class ComparatorController < ApplicationController
	before_action :set_comparator
	before_action :authenticate_user!
	before_action :set_product, only: [:add_product, :remove_product]
	load_and_authorize_resource

	def add_product
		if !@comparator.products.include?(@product)
			@success, @message = @comparator.add_product(@product)
		end
		respond_js
	end

	def remove_product
		@success = @comparator.remove_product(@product)
		respond_js
	end

	def index
	end

	def empty
		@success = (@comparator.comparator_products.destroy_all ? true : false)
		respond_js
	end

	def back_and_empty
		if @comparator.products.size == 0
			redirect_to business_units_path
		else
			business_unit = @comparator.products.first.families.find_by(depth: 0).name
			@comparator.comparator_products.destroy_all
			redirect_to products_path(business_unit: business_unit)
		end
	end

	private

	def set_comparator
		@comparator = Comparator.find_or_create_by(user: current_user)
	end

	def set_product
		@product = Product.find_by(id: params[:id])
	end
end