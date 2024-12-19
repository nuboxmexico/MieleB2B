FactoryBot.define do
  factory :retail do
    name { "MyString" }

    factory :falabella do 
    	name {'Falabella'}
    end

    factory :linio do 
    	name {'Linio'}
    end

    factory :travel do 
    	name {'Travel'}
    end

    factory :paris do 
    	name {'Paris'}
    end

    factory :bci do 
        name {'BCI'}
    end

    factory :itau do 
        name {'Itau'}
    end

    factory :hbt do 
        name {'HBT'}
    end

     factory :kitchencenter do 
        name {'KITCHENCENTER'}
    end
  end
end
