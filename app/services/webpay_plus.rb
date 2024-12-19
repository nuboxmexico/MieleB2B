class WebpayPlus 
  URL_BASE = Rails.env.production? ? 'https://webpay3g.transbank.cl' : 'https://webpay3gint.transbank.cl'

  def self.init_transaction(order)
    unless order.respond_to?(:webpay_object_data)
      undefined_method_webpay_object_data_error(order)
    end

    response = api_connection.post do |req|
      req.url '/rswebpaytransaction/api/webpay/v1.0/transactions'
      req.body = order.webpay_object_data.merge({
        return_url: url_helpers.webpay_return_url(app_host)
      }).to_json
    end

    if (response = process_response(response))
      return Net::HTTP.post_form(URI(response['url']), token_ws: response['token'])
    else
      return nil
    end
  end

  def self.transaction_confirmation(webpay_token)
    response = api_connection.put do |req|
      req.url "/rswebpaytransaction/api/webpay/v1.0/transactions/#{webpay_token}"
    end
    
    # WARNING
    # Use this only if the app have an old data structure and you have to provide backward compatibility
    if (response = process_response(response))
      response['legacy_format'] = response_to_a(response)
      return response
    else
      return nil
    end
  end

  private 
    def self.api_connection
      return Faraday.new(
        url: URL_BASE,
        headers: request_headers
      )
    end

    def self.request_headers
      return {
        'Tbk-Api-Key-Id' => Rails.application.secrets.webpay[:key_id],
        'Tbk-Api-Key-Secret' => Rails.application.secrets.webpay[:key_secret],
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

    def self.app_host
      Rails.application.config.action_mailer.default_url_options
    end

    def self.url_helpers
      Rails.application.routes.url_helpers
    end

    # WARNING
    # Use this only if the app have an old data structure and you have to provide backward compatibility
    def self.response_to_a(webpay_response)
      url_redirection = ''
      return [
        webpay_response['status'],
        webpay_response['accounting_date'],
        webpay_response['card_detail']['card_number'],
        webpay_response['amount'],
        webpay_response['authorization_code'],
        webpay_response['payment_type_code'],
        webpay_response['response_code'],
        webpay_response['transaction_date'],
        url_redirection,
        webpay_response['vci'],
        webpay_response['installments_number']
      ]
    end

    def self.undefined_method_webpay_object_data_error(order)
      # webpay_object_data method expected return
      # {
      #   buy_order: <ORDER UNIQUE ID OR CODE>,
      #   session_id: <NUMBER TO IDENTIFY SESSION. IF YOU DO NOT HAVE. USE THIS: rand(1111111..9999999).to_s>,
      #   amount: <ORDER TOTAL AMOUNT>
      # }

      raise "Method Missing. You must implement 'webpay_object_data' on '#{order.class}' class. 
            Check this raised error to see data structure."
    end
end