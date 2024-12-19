FactoryBot.define do
  factory :project_installation_value do
    min_amount { 1 }
    max_amount { 1 }
    cost_RM { "9" }
    cost_additional_region { "9" }
  end
end
