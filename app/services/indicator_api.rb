class IndicatorApi
  #Doc: https://mindicador.cl/

  #Salida: 
  # version: "1.2"
  # autor: "asd"
  # fecha: "2022-03-10T17:00:00.000Z"
  # uf:{
  #   codigo: "uf",
  #   nombre: "Unidad de fomento (UF)",
  #   unidad_medida: "pesos",
  #   fecha: "2022-03-10T03:00:00.000Z",
  #   valor: 31663.42
  # },
  # ivp:{

  # }
  def self.get_all_indicators
    response = api_connection.get do |req|
      req.url ""
    end
    return process_response(response)
  end

  #Salida:
  # version: "1.2"
  # autor: "asd"
  # codigo: "uf"
  # nombre: "Unidad de fomento (UF)"
  # unidad_medida: "pesos"
  # serie:[
  #   {
  #     fecha: "2022-03-10T03:00:00.000Z",
  #     valor: 31663.42
  #   },
  #   {
  #     fecha: "2022-03-09T03:00:00.000Z",
  #     valor: 31660.36
  #   }
  # ]
  def self.get_indicator(indicator)
    response = api_connection.get do |req|
      req.url "#{indicator}"
    end
    return process_response(response)
  end

  private 
    def self.api_connection
      return Faraday.new(
        url: "https://mindicador.cl/api/"
      )
    end

    def self.process_response(response)
      if response.status == 200
        return JSON.parse(response.body)
      else
        return nil
      end
    end
end