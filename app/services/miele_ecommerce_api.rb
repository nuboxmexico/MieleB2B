class MieleEcommerceApi

  def self.update_state_of_b2c_order(order_id,state)
    response = api_connection.patch do |req|
      req.url "/api2/v1/update_state_order"
      req.body = {
          order_id:order_id, 
          new_state_order:state
      }.to_json
    end
    
    return process_response(response)
  end

  private 
    def self.api_connection
      return Faraday.new(
        url: Rails.application.secrets.miele_b2c_api[:url_base],
        headers: request_headers
      )
    end

    def self.request_headers
      return {
        'Authorization' => "Token token=#{Rails.application.secrets.miele_b2c_api[:token]}",
        'Content-Type' => 'application/json'
      }
    end

    def self.process_response(response)
      #if response.status == 200
        return JSON.parse(response.body)
      #else
      #  return nil
      #end
    end
end