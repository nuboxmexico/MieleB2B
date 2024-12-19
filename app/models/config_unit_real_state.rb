class ConfigUnitRealState < ApplicationRecord
    belongs_to :quotation
    has_many :product_in_unit_real_states, dependent: :destroy
    before_create :set_config_uuid

    def set_config_uuid
        self.config_uuid = SecureRandom.uuid
    end

    def self.replicate_in_core(quotation)
        @project = MieleCoreApi.find_project_by_code(quotation.code)
        if @project && @project['result'] == 'Found'
            data = { project_id: @project['id'].to_i, unit_and_products: [] }
            quotation.config_unit_real_states.each do |u|
                unit_data = {
                    uuid: u.config_uuid,
                    type: u.config_type,
                    number: u.config_number,
                    products: []
                }
                u.product_in_unit_real_states.each do |piu|
                    product_data = {
                        name: piu.name,
                        tnr: piu.sku,
                        quantity: piu.quantity,
                        instalation: piu.quotation_product.instalation,
                        is_home_program: piu.quotation_product.is_service && piu.sku == "PEM"
                    }
                    unit_data[:products] << product_data
                end
                data[:unit_and_products] << unit_data
            end
            MieleCoreApi.create_unit_real_state(@project['id'].to_i , data)
        end
    end

    def remove_this_product(quotation_product)
        self.product_in_unit_real_states.each do |product_in_unit|
          product_in_unit.destroy if product_in_unit.quotation_product_id == quotation_product.id
        end
    end
end
