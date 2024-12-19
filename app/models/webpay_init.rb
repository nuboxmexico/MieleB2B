class WebpayInit
    #Normal transacition
    def self.init_transaction(payment, base_url)
    	puts 'start init transaction'
    	self.init_webpay(base_url)
    	amount = payment.ammount.to_i
    	sessionId = rand(1111111..9999999).to_s
    	payment.update(tbk_transaction_id: sessionId)
    	return @webpay.getNormalTransaction.initTransaction(amount, payment.miele_tx_code, sessionId, @urlReturn, @urlFinal)
    end

    def self.get_transaction_result(token, base_url)
    	self.init_webpay(base_url)
    	return @webpay.getNormalTransaction.getTransactionResult(token)
    end

    def self.acknowledge_transaction(token, base_url)
    	self.init_webpay(base_url)
    	return @webpay.getNormalTransaction.acknowledgeTransaction(token)
    end    

    def self.nullify_transaction(token, base_url, authorizationCode, authorizedAmount, buyOrder, nullifyAmount)
    	self.init_webpay(base_url)
    	return @webpay.getNullifyTransaction.nullify(authorizationCode, authorizedAmount, buyOrder, nullifyAmount, Rails.application.secrets.webpay_commerce_code.to_s)
    end           



     #Logger
     def self.log(action, id, type, payload_text, sessionId)
     	puts 'Saving webpay logs'
     	begin
     		file = Rails.application.secrets.webpay_logger
     		puts 'archivo: ' + file
     		directory = Rails.root.join('log', file)
     		time = Time.now.to_s

     		File.open(directory, 'a+') do |f|
     			if type.to_s == "request" && action.to_s == "init_transaction"
     				source = payload_text
     				response_document = Nokogiri::HTML(source.to_s)     
     				f << action.to_s + ': ' + time.to_s + "\n"
     				f << type.upcase.to_s + "\n"
     				f << '(' + "\n"
     				f << "\t" + "[wSTransactionType] => \'TR_NORMAL_WS\'" + "\n"
            #f << "\t [commerceId] => " + Rails.application.secrets.webpay_commerce_code.to_s + "\n"
            f << "\t [buyOrder] => " + id.to_s.split(':')[1].to_s + "\n"
            f << "\t [sessionId] =>" + sessionId.to_s + "\n"
            f << "\t [returnURL] => https://frutaconsentido.com" + Rails.application.secrets.webpay_return_url.to_s + "\n"
            f << "\t [finalURL] https://frutaconsentido.com" + Rails.application.secrets.webpay_final_url.to_s + "\n"
            f << "\t [transactionDetails]" + "\n"
            f << "\t (" + "\n"
            f << "\t\t [amount] => " + response_document.xpath("//amount").text.to_s + "\n"
            f << "\t\t [commerceCode] => " + Rails.application.secrets.webpay_commerce_code.to_s + "\n"
            f << "\t\t [buyOrder] =>" + id.to_s.split(':')[1].to_s + "\n"
            f << "\t )" + "\n"


        elsif  type.to_s == "response" && action.to_s == "init_transaction"

        	source = payload_text
        	source =  JSON.parse(source.gsub("=>",":").to_s)
        	f << "RESPONSE" + "\n"
        	f << "(" + "\n"
        	f << "\t\t [token] =>" + source["token"].to_s + "\n"
        	f << "\t\t [url] =>" + source["url"].to_s + "\n"
        	f << ")" + "\n"

        elsif  type.to_s == "request" && action.to_s == "get_transaction_result"  
        	f << action.to_s + ': ' + time.to_s + "\n"
        	f << type.upcase.to_s + "\n"
        	f << '(' + "\n"
        	f << "\t" + "[tokenInput] =>" + sessionId + "\n"
        	f << ")" + "\n"

        elsif  type.to_s == "response" && action.to_s == "get_transaction_result"


        	response_document= Nokogiri::HTML(sessionId.to_s)

        	accountingdate    = response_document.xpath("//accountingdate").text
        	buyorder          = response_document.at_xpath("//buyorder").text
        	cardnumber        = response_document.xpath("//cardnumber").text
        	sharesnumber      = response_document.xpath("//sharesnumber").text
        	amount            = response_document.xpath("//amount").text
        	commercecode      = response_document.xpath("//commercecode").text

        	authorizationcode = response_document.xpath("//authorizationcode").text
        	paymenttypecode   = response_document.xpath("//paymenttypecode").text
        	responsecode      = response_document.xpath("//responsecode").text
        	transactiondate   = response_document.xpath("//transactiondate").text
        	urlredirection    = response_document.xpath("//urlredirection").text
        	sessionid    = response_document.xpath("//sessionid").text
        	vci               = response_document.xpath("//vci").text


        	f << type.upcase.to_s + "\n"
        	f << '(' + "\n"
        	f << "\t [accountingDate] =>" + accountingdate + "\n"
        	f << "\t [buyOrder] => " + buyorder +  "\n"


        	f << "\t [cardDetail] =>" + "\n"
        	f << "\t (" + "\n"
        	f << "\t\t [cardNumber] =>" + cardnumber  + "\n"

        	f << "\t )" + "\n"

        	f << "\t [detailOutput] =>" + "\n"
        	f << "\t (" + "\n"
        	f << "\t\t [authorizationCode] => " + authorizationcode + " \n"
        	f << "\t\t [paymentTypeCode] => " + paymenttypecode + "\n"
        	f << "\t\t [responseCode] => " + responsecode + " \n"
        	f << "\t\t [sharesNumber] => " + sharesnumber + "\n"
        	f << "\t\t [amount] => " + amount + " \n"
        	f << "\t\t [commerceCode] => " + commercecode + " \n"
        	f << "\t\t [buyOrder] => " + buyorder + "  \n"                   
        	f << "\t )" + "\n"


        	f << "\t [sessionId] =>" + sessionid +"\n"
        	f << "\t [transactionDate] => " + transactiondate  + "\n"
        	f << "\t [urlRedirection] => " + urlredirection + "\n"
        	f << "\t [VCI] => " +  vci + "\n"          
        	f << ')' + "\n"
        elsif  type.to_s == "request" && action.to_s == "acknowledge_transaction"
        	f << action.to_s + ': ' + time.to_s + "\n"
        	f << type.upcase.to_s + "\n"
        	f << '(' + "\n"
        	f << "\t [tokenInput] => " + sessionId + " \n"
        	f << ')' + "\n"
        elsif  type.to_s == "response" && action.to_s == "acknowledge_transaction"
        	f << type.upcase.to_s + "\n"
        	f << '(' + "\n"
        	f << ')' + "\n"
        else


        end

          #f << time.to_s + "\t" + action.to_s + "\t" + id.to_s + "\t" + type.to_s + "\t" + payload_text.to_s + "\n" + "\n"
      end
  rescue
  	puts 'Ha ocurrido un error guardando los logs de WebPay'
  end

end

private
def self.init_webpay(base_url)
	libwebpay = Libwebpay.new
	config = libwebpay.getConfiguration
	config.commerce_code = Rails.application.secrets.webpay_commerce_code
	config.environment = Rails.application.secrets.webpay_ambient
	config.private_key = OpenSSL::PKey::RSA.new(File.read(Rails.application.secrets.webpay_client_private_key))
	config.public_cert = OpenSSL::X509::Certificate.new(File.read(Rails.application.secrets.webpay_client_certificate))
	config.webpay_cert = OpenSSL::X509::Certificate.new(File.read(Rails.application.secrets.webpay_tbk_certificate))        
	puts 'commerce code: ' + Rails.application.secrets.webpay_commerce_code.to_s
	puts 'env: ' + Rails.application.secrets.webpay_ambient.to_s
	puts 'private_key: ' + OpenSSL::PKey::RSA.new(File.read(Rails.application.secrets.webpay_client_private_key)).to_s
	puts 'public_cert: ' + OpenSSL::X509::Certificate.new(File.read(Rails.application.secrets.webpay_client_certificate)).to_s
	puts 'webpay_cert: ' + OpenSSL::X509::Certificate.new(File.read(Rails.application.secrets.webpay_tbk_certificate)).to_s

	@webpay = libwebpay.getWebpay(config)
	@urlReturn = base_url + Rails.application.secrets.webpay_return_url.to_s
	@urlFinal = base_url + Rails.application.secrets.webpay_final_url.to_s
end               

end