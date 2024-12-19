FactoryBot.define do
  factory :user do
    email    {'oferusat@gmail.com'}
    name     {'Administrador'}
    lastname {'Test'}
    second_lastname {'Materno'}
    password {'123456'}
    role     {Role.find_by(name: 'Administrador') || create(:role)}
    shop {'Vitacura'}
    cost_center {CostCenter.first || create(:cost_center)}
    workday {'Full Time'}
    phone {'987654321'}
    miele_role {MieleRole.last || create(:miele_role)}
    active {true}

    factory :user_deactivated do 
      email    {'seller@gmail.com'}
      name     {'Seller'}
      lastname {'Test'}
      password {'123456'}
      role     {Role.find_by(name: 'Seller') || create(:role)}
      shop {'Vitacura'}
      cost_center {CostCenter.first || create(:cost_center)}
      workday {'Full Time'}
      phone {'987654321'}
      active {false}
    end

    factory :manager_user do 
      name {'Manager'}
      email {'manager@test.net'}
      role {Role.find_by(name: 'Manager') || create(:manager_role)}
      sale_channel {SaleChannel.find_by(name: 'E-commerce') || create(:ecommerce_sale_channel)}

      after(:create) do |user|
          create(:custom_role, user: user, role: Role.find_by(name: 'Manager'), sale_channel: SaleChannel.find_by(name: 'E-commerce'), cost_center: CostCenter.first)
      end
    end

    factory :finance_user do 
      email {'finance@test.net'}
      name {'Finance'}
      role {Role.find_by(name: 'Finanzas') || create(:finance_role)}
    end

    factory :manager_finance_user do 
      email {'mfinance@test.net'}
      name {'Manager Finanzas'}
      role {Role.find_by(name: 'Manager Finanzas') || create(:finance_manager_role)}
    end

    factory :foreign_user do 
      email {'foreigne@test.net'}
      name {'Consultivo'}
      role {Role.find_by(name: 'Consultivo') || create(:foreign_role)}
    end

    factory :manager_dispatch_user do 
      email {'mdispatch@test.net'}
      name {'Despacho M'}
      role {Role.find_by(name: 'Manager Despacho') || create(:dispatch_manager_role)}
    end

    factory :manager_instalation_user do 
      email {'minstalation@test.net'}
      name {'Instalación M'}
      role {Role.find_by(name: 'Manager Instalación') || create(:instalation_manager_role)}
    end

    factory :seller_user do 
      email {'seller@test.net'}
      name {'Vendedor'}
      role {Role.find_by(name: 'Seller') || create(:seller_role)}
      sale_channel {SaleChannel.find_by(name: 'MCA') || create(:sale_channel_with_product)}
    end

    factory :retail_user do 
      email {'retail@test.net'}
      name {'Manager'}
      lastname {'Retail'}
      role {Role.find_by(name: 'Manager') || create(:manager_role)}
      sale_channel {SaleChannel.find_by(name: 'Retail') || create(:retail_sale_channel)}
    end

    factory :mca_user do 
      email {'mca@test.net'}
      name {'Manager'}
      lastname {'MCA'}
      role {Role.find_by(name: 'Manager') || create(:manager_role)}
      sale_channel {SaleChannel.find_by(name: 'MCA') || create(:sale_channel)}
    end

    factory :project_user do 
      email {'project@test.net'}
      name {'Manager'}
      lastname {'Proyectos'}
      role {Role.find_by(name: 'Manager') || create(:manager_role)}
      sale_channel {SaleChannel.find_by(name: 'Proyectos') || create(:project_business_sale_channel)}
    end

    factory :mca_seller_user do 
      email {'mca_seller@test.net'}
      name {'Seller'}
      lastname {'MCA'}
      role {Role.find_by(name: 'Seller') || create(:seller_role)}
      sale_channel {SaleChannel.find_by(name: 'MCA') || create(:sale_channel)}
    end
  end
end
