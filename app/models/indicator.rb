class Indicator < ApplicationRecord

    def self.update_indicators
        list_indicators = ["uf", "euro"]
        indicator_data = IndicatorApi.get_all_indicators
        list_indicators.each do |i|
            indicator = Indicator.where(name: i).take
            if indicator
                indicator.update(value: indicator_data[i]["valor"])
            else
                Indicator.create(name: i, value: indicator_data[i]["valor"])
            end
        end

    end
end
