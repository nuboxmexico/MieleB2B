FactoryBot.define do
  factory :cost_center do
    code { 36 }
    name { "Web Shop" }

    factory :miele_exp_center do 
    	code {22}
    	name {'Miele Experience Center'}
    end

    factory :piedra_roja do 
    	code {47}
    	name {'Miele Point - Piedra Roja'}
    end
  end
end
