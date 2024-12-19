SimpleTokenAuthentication.configure do |config|
	config.sign_in_token = true
	config.header_names = { user: { authentication_token: 'User-Token', email: 'User-Email' } }
end