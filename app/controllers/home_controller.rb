class HomeController < ApplicationController
	def index
		if current_user.foreign? or current_user.seller?
			redirect_to business_units_path
		elsif current_user.manager?
			@quotations = current_user.sale_channel.quotations.order("updated_at DESC").limit(5)
			@quotations_by_state = Dashboard.quotations_by_state(current_user)
			@quotations_per_channel = Dashboard.quotations_per_channel(current_user)
			@products_most_selled = Dashboard.products_most_selled(current_user)
			@quotations_per_channel_and_product_type = Dashboard.quotation_products_per_channel_and_product_type(current_user)
		elsif current_user.administrator? or current_user.is_manager_inventory?
			@quotations = Quotation.all.order("updated_at DESC").limit(5)
			@quotations_by_state = Dashboard.quotations_by_state(current_user)
			@quotations_per_channel = Dashboard.quotations_per_channel(current_user)
			@products_most_selled = Dashboard.products_most_selled(current_user)
			@quotations_per_channel_and_product_type = Dashboard.quotation_products_per_channel_and_product_type(current_user)
		else
			redirect_to quotations_path
		end
	end

	def filter
		range_date = params[:date_range].split(' - ')
		start_date = DateTime.parse(range_date[0]).beginning_of_day
		end_date = DateTime.parse(range_date[1]).end_of_day
		@quotations_by_state = Dashboard.quotations_by_state(current_user, start_date, end_date)
		@quotations_per_channel = Dashboard.quotations_per_channel(current_user, start_date, end_date)
		@products_most_selled = Dashboard.products_most_selled(current_user, start_date, end_date)
		respond_to do |format|
			format.js
		end
	end
end
