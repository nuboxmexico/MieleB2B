class ProductInUnitRealStatesController < ApplicationController
    before_action :set_product_in_unit_real_state, only: [ :destroy ]
    before_action :set_what_refresh, only: [ :create_or_update, :destroy ]

    def get_current_quantity
        unless params[:urs].nil? || params[:qp].nil?
            product_in_unit_arr = ProductInUnitRealState.where(quotation_product_id: params[:qp].to_i, config_unit_real_state_id: params[:urs].to_i)
            unless product_in_unit_arr.empty? 
                product_in_unit = product_in_unit_arr.take
                render json: { quantity: product_in_unit.quantity }, status: :ok
            else
                render json: { quantity: 0 }, status: :ok
            end
        end
    end

    def create_or_update
        data = create_or_update_params
        products_as_hash = create_or_update_params['products']
        keys = products_as_hash.keys
        products_as_arr = []
        keys.each { |key| products_as_arr << products_as_hash[key] }
        data['products'] = products_as_arr     
        
        config_unit_id = data['config_unit_id'].to_i
        quotation = ConfigUnitRealState.find(config_unit_id).quotation

        products_as_arr.each do |p|
            product_in_unit_arr = ProductInUnitRealState.where(quotation_product_id: p['id'].to_i, config_unit_real_state_id: config_unit_id)
            quotation_product = QuotationProduct.find(p['id'].to_i)            

            # If exists, update it; else, create it. If quantity is zero, destroy or not create it.
            unless product_in_unit_arr.empty?
                product_in_unit = product_in_unit_arr.take
                product_in_unit.update(quantity: p['quantity'].to_i)
                product_in_unit.destroy if p['quantity'].to_i == 0
            else
                unless p['quantity'].to_i == 0
                    ProductInUnitRealState.create(
                        name: quotation_product.name,
                        sku: quotation_product.sku,
                        config_unit_real_state_id: config_unit_id,
                        quotation_product_id: p['id'].to_i,
                        quantity: p['quantity'].to_i
                    )
                end
            end

            # Quantity Assigned
            if quotation_product.quantity_assigned.nil? || quotation_product.quantity_assigned == 0
                quotation_product.update(quantity_assigned: p['quantity'].to_i)
            else
                config_units = ConfigUnitRealState.find(config_unit_id).quotation.config_unit_real_states
                counter = 0
                config_units.each do |unit|
                    unit.product_in_unit_real_states.each do |prod_in_unit|
                        counter += prod_in_unit.quantity if prod_in_unit.quotation_product_id == p['id'].to_i
                    end
                end
                quotation_product.update(quantity_assigned: counter)
            end
        end

        replicate_in_core(quotation)

        respond_to do |format|
            format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: quotation, what_refresh: @what_refresh } }
        end
    end

    def destroy
        units = @product_in_unit_real_state.config_unit_real_state.quotation.config_unit_real_states
        quotation = @product_in_unit_real_state.config_unit_real_state.quotation
        quotation_product = @product_in_unit_real_state.quotation_product
        
        @product_in_unit_real_state.destroy

        counter = 0
        units.each do |unit|
            unit.product_in_unit_real_states.each do |prod_in_unit|
                counter += prod_in_unit.quantity if prod_in_unit.quotation_product_id == quotation_product.id
            end
        end
        quotation_product.update(quantity_assigned: counter)

        replicate_in_core(quotation)

        respond_to do |format|
            format.js { render partial: 'quotations/update_products_tab_project', locals: { quotation: quotation, what_refresh: @what_refresh } }
        end
    end

    private

    def set_what_refresh
        @what_refresh = { installation_box: false,
            all_unit_real_states: false,
            dispatch_groups_container: false,
            dispatch_stats: false,
            all_config_unit_real_states: true,
            glosa: false
        }
    end

    def set_product_in_unit_real_state
        @product_in_unit_real_state = ProductInUnitRealState.find(params[:id])
    end

    def create_or_update_params
        params.permit(
          :config_unit_id,
          products: [
            :id,
            :quantity
          ]
        )
    end

    def replicate_in_core(quotation)
        ConfigUnitRealState.replicate_in_core(quotation)
    end
end
