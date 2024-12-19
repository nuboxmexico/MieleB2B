FactoryBot.define do
  factory :customer do
    name {'Usuario'}
    lastname {'prueba'}
    second_lastname {'materno'}
    rut {'11111111-1'}
    email {'hola@prueba.net'}
    phone {987654321}
    dispatch_address {'Calle falsa'}
    dispatch_address_number {'123'}
    dispatch_dpto_number {'1116'}
    dispatch_commune {Commune.last || create(:santiago)}
    personal_address {'Calle verdadera'}
    personal_address_number {'456'}
    personal_dpto_number {'982'}
    personal_commune {Commune.find_by(name: 'Providencia') || create(:providencia)}
    instalation_address {'Calle ultra falsa'}
    instalation_address_number {'789'}
    instalation_dpto_number {'012'}
    instalation_commune {Commune.find_by(name: 'Recoleta') || create(:recoleta)}

    factory :customer_retail do 
      name {'Retail'}
      lastname {'prueba'}
      second_lastname {'materno'}
      rut {'11111111-1'}
      email {'hola@prueba.net'}
      phone {987654321}
      dispatch_address {'Calle falsa 123'}
      dispatch_address_number {nil}
      dispatch_dpto_number {nil}
      dispatch_commune {Commune.last || create(:santiago)}
      personal_address {nil}
      personal_address_number {nil}
      personal_dpto_number {nil}
      personal_commune {nil}
      instalation_address {nil}
      instalation_address_number {nil}
      instalation_dpto_number {nil}
      instalation_commune {nil}
    end
  end
end
