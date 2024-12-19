class UnitRealState < ApplicationRecord
    belongs_to :quotation

    def partial_to_display
        'quotations/checkout/new_unit_real_state_box'
    end

    def calculate_values
        costs = self.get_cost_rm_and_region(self.products_quantity)

        if self.is_rm
            unit_value = (costs[0] * self.products_quantity).round(2)
            total_value = (costs[0] * self.products_quantity * self.quantity).round(2)
        else
            unit_value = ((costs[0] + costs[1]) * self.products_quantity).round(2)
            total_value = ((costs[0] + costs[1]) * self.products_quantity * self.quantity).round(2)
        end

        self.update(unit_value: unit_value)
        self.update(total_value: total_value)
    end

    def clp_to_UF_instalation_value
        project_installation_values_aux = []
        ProjectInstallationValue.all.each do |indicator|
            project_installation_values_aux.push({
            min_amount: indicator.min_amount,
            max_amount: indicator.max_amount,
            cost_RM: CartHelper.clp_to_UF(indicator.cost_RM),
            cost_additional_region:  CartHelper.clp_to_UF(indicator.cost_additional_region)
            })
        end
        project_installation_values_aux
    end

    def get_cost_rm_and_region(products_quantity)
        project_installation_values = self.clp_to_UF_instalation_value
        cost_rm = 0
        cost_region = 0
        project_installation_values.each do |value|
            if products_quantity >= value[:min_amount] && products_quantity<=value[:max_amount]
                cost_rm = value[:cost_RM]
                cost_region = value[:cost_additional_region]
                break
            end
        end
        return [cost_rm, cost_region]
    end
end
