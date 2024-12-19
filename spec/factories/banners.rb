FactoryBot.define do
  factory :banner do
    url { "" }
    start_date { "2020-04-16" }
    end_date { "2020-04-16" }

    factory :banner_expired do 
    	start_date {"2020-03-01"}
    	end_date {"2020-03-30"}
    end
  end
end
