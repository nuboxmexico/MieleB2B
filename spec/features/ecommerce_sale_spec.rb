require 'rails_helper'
describe 'Ecommerce Sale', type: :request do 
	let(:user){create(:user)}
	let(:headers){{ "CONTENT_TYPE" => "application/json", "User-Email" => user.email, "User-Token" => user.authentication_token}}

	context 'Write' do
		it 'post success sale' do
			params = File.read(Rails.root+"spec/aux/sale_ok.json")
			create(:product, sku: '7006550')
			create(:product, sku: '9553030')
			post '/ecommerce_sales.json', params: params, headers: headers
			expect(response).to have_http_status(:ok)
			expect(EcommerceSale.all.size).to eq 1
		end

		it 'post without sales' do
			params = {'ecommerce_sales': []}
			post '/ecommerce_sales.json', params: params.to_json, headers: headers
			expect(response).to have_http_status(:internal_server_error)
			expect(ActiveSupport::JSON.decode(response.body)["error"]).to eq "No tienes Ventas del ecommerce."
			expect(ActiveSupport::JSON.decode(response.body)["failed"]).to eq nil
		end

		it 'post without field' do
			params = File.read(Rails.root+"spec/aux/sale_error_field.json")
			post '/ecommerce_sales.json', params: params, headers: headers
			expect(response).to have_http_status(:internal_server_error)
			expect(ActiveSupport::JSON.decode(response.body)["error"]).to eq "Hubo un error en el request: Falta número de orden"
			expect(ActiveSupport::JSON.decode(response.body)["failed"]).to eq []
		end

		it 'post without products' do
			params = File.read(Rails.root+"spec/aux/sale_error_product.json")
			post '/ecommerce_sales.json', params: params, headers: headers
			expect(response).to have_http_status(:internal_server_error)
			expect(ActiveSupport::JSON.decode(response.body)["error"]).to eq "Algunas ventas no se han podido escribir."
			expect(ActiveSupport::JSON.decode(response.body)["failed"]).to eq ["R9182301"]
		end
	end

	context 'Read' do 
		it 'get stock' do
			create(:product, sku: '9553030')
			params = {"tnrs": ["9553030"]}
			get '/get_stock.json', params: params, headers: headers
			expect(response).to have_http_status(:ok)
			expect(ActiveSupport::JSON.decode(response.body)["9553030"]).to eq 30
		end

		it 'get stock without tnrs' do
			params = {"tnrs": []}
			get '/get_stock.json', params: params, headers: headers
			expect(response).to have_http_status(:ok)
			expect(response.body).to eq "{}"
		end

		it 'get stock without body' do
			params = {}
			get '/get_stock.json', params: params, headers: headers
			expect(response).to have_http_status(:internal_server_error)
			expect(ActiveSupport::JSON.decode(response.body)["error"]).to eq "Hubo un error en el request: Faltan TNRs!"
		end
	end

	context 'Write Stock' do 
		before do 
			create(:product, sku: '9553030')
		end

		it 'discount success' do 
			params = File.read(Rails.root+"spec/aux/stock_success.json")
			post '/discount_stock.json', params: params, headers: headers
			expect(response).to have_http_status(:ok)
			expect(Product.last.stock).to eq 28
		end

		it 'discount with missing field' do 
			params = File.read(Rails.root+"spec/aux/stock_error_field.json")
			post '/discount_stock.json', params: params, headers: headers
			expect(response).to have_http_status(:internal_server_error)
			expect(ActiveSupport::JSON.decode(response.body)["error"]).to eq "Hubo un error en el request: Falta cantidad de producto"
		end

		it 'discount without body' do 
			post '/discount_stock.json', params: {}, headers: headers
			expect(response).to have_http_status(:internal_server_error)
			expect(ActiveSupport::JSON.decode(response.body)["error"]).to eq "Hubo un error en el request: Faltan productos de la venta"
		end

		it 'discount without products' do 
			params = File.read(Rails.root+"spec/aux/stock_error_products.json")
			post '/discount_stock.json', params: params, headers: headers
			expect(response).to have_http_status(:internal_server_error)
			expect(ActiveSupport::JSON.decode(response.body)["error"]).to eq "No haz enviado productos para descontar stock."
		end

		it 'reverse success' do 
			params = File.read(Rails.root+"spec/aux/stock_success.json")
			post '/reverse_stock.json', params: params, headers: headers
			expect(response).to have_http_status(:ok)
			expect(Product.last.stock).to eq 32
		end

		it 'reverse with missing field' do 
			params = File.read(Rails.root+"spec/aux/stock_error_field.json")
			post '/reverse_stock.json', params: params, headers: headers
			expect(response).to have_http_status(:internal_server_error)
			expect(ActiveSupport::JSON.decode(response.body)["error"]).to eq "Hubo un error en el request: Falta cantidad de producto"
		end

		it 'reverse without body' do 
			post '/reverse_stock.json', params: {}, headers: headers
			expect(response).to have_http_status(:internal_server_error)
			expect(ActiveSupport::JSON.decode(response.body)["error"]).to eq "Hubo un error en el request: Faltan productos de la venta"
		end

		it 'reverse without products' do 
			params = File.read(Rails.root+"spec/aux/stock_error_products.json")
			post '/reverse_stock.json', params: params, headers: headers
			expect(response).to have_http_status(:internal_server_error)
			expect(ActiveSupport::JSON.decode(response.body)["error"]).to eq "No haz enviado productos para reponer stock."
		end
	end
end