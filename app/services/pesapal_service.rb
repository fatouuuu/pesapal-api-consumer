module PesapalService
    PESAPAL_BASE_URL = Rails.env.production? ? 'https://pay.pesapal.com/v3' : 'https://cybqa.pesapal.com/pesapalv3'
    AUTHENTICATION_URL = Rails.env.production? ? 'https://pay.pesapal.com/v3/api/Auth/RequestToken' : 'https://cybqa.pesapal.com/pesapalv3/api/Auth/RequestToken'
    REGISTER_IPN_URL = Rails.env.production? ? 'https://pay.pesapal.com/v3/api/URLSetup/RegisterIPN' : 'https://cybqa.pesapal.com/pesapalv3/api/URLSetup/RegisterIPN'
    SUBMIT_ORDER_REQUEST_URL = Rails.env.production? ? 'https://pay.pesapal.com/v3/api/Transactions/SubmitOrderRequest' : 'https://cybqa.pesapal.com/pesapalv3/api/Transactions/SubmitOrderRequest'
  
  
    def self.authorization_header(auth_token)
      {
        'Accept' => 'application/json',
        'Content-Type' => 'application/json',
        'Authorization' => "Bearer #{auth_token}"
      }
    end
  
    def self.handle_error_response(response)
        response_body = JSON.parse(response.body)
        error_code = response_body['code']
        error_message = response_body['message']
        render json: { error_code: error_code, error_message: error_message }, status: response.code
    end
end
  