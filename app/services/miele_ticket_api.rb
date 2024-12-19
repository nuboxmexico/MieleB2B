class MieleTicketApi

  def self.get_all_technicians(pais)
    response = api_connection.get do |req|
      req.url "/api/v1/technicians?country=#{pais}"
    end
    return process_response(response)
  end

  def self.create_customer(customer_hash)
    response = api_connection.post do |req|
      req.url '/api/v1/customers'
      req.body = customer_hash.to_json
    end

    return process_response(response)
  end

  private

  def self.api_connection
    return Faraday.new(
      url: Rails.application.secrets.miele_ticket_api[:url_base],
      headers: request_headers
    )
  end

  def self.request_headers
    return {
      'Authorization' => "Token token=#{Rails.application.secrets.miele_ticket_api[:token]}",
      'Content-Type' => 'application/json'
    }
  end

  def self.process_response(response)
    if response.status == 200
      return JSON.parse(response.body)
    else
      return nil
    end
  end
end