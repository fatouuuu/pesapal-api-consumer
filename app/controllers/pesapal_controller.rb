class PesapalController < ApplicationController
    include PesapalService
    skip_before_action :verify_authenticity_token, only: [:callback, :register_ipn, :authorization, :pesapal_iframe]
    
    def authorization
      auth_payload = {
        consumer_key: ENV.fetch('PESAPAL_CONSUMER_KEY', params[:consumer_key]),
        consumer_secret: ENV.fetch('PESAPAL_CONSUMER_SECRET', params[:consumer_secret])
      }
  
      response = HTTParty.post(AUTHENTICATION_URL, headers: { 'Content-Type' => 'application/json' }, body: auth_payload.to_json)
      
      if response.code == 200
        response_body = JSON.parse(response.body)
        session[:auth_token] = response_body['token'] #save token to session
        render json: response_body
      else
        PesapalService.handle_error_response(response)
      end
    end
  

    def register_ipn 
        ipn_payload = {
          url: params[:url], #IPN URL
          ipn_notification_type: 'POST'
        }
        auth_token = session[:auth_token] #retrieve token from session
    
        if auth_token.nil?
          render json: { error: 'Authorization token not found. Please authorize first.' }, status: :unauthorized
          return
        end
    
        response = HTTParty.post(REGISTER_IPN_URL, headers: PesapalService.authorization_header(auth_token), body: ipn_payload.to_json)
        if response.code == 200
          response_body = JSON.parse(response.body)
          session[:ipn_id] = response_body['ipn_id'] #save IPN ID to session
          render json: response_body
        else
          # parse error details only from the response
          error_response = JSON.parse(response.body)["error"]
          render json: error_response, status: response.code
        end    
    end 
    
      
  

  
    def callback
        pesapal_transaction_tracking_id = params[:pesapal_transaction_tracking_id]
        merchant_reference = params[:merchant_reference]
        status = params[:status]
      
        if status == 'COMPLETED'
          # Payment successful
          payment = Payment.find_by(pesapal_transaction_tracking_id: pesapal_transaction_tracking_id)
          if payment
            payment.update(status: 'COMPLETED')
            Rails.logger.info("Payment #{pesapal_transaction_tracking_id} successfully updated to COMPLETED.")
          else
            Rails.logger.error("Payment not found for transaction #{pesapal_transaction_tracking_id}.")
          end
      
          # respond with a success message
          render json: 'Payment successful', status: :ok
        elsif status == 'FAILED'
          # Payment failed
      
          payment = Payment.find_by(pesapal_transaction_tracking_id: pesapal_transaction_tracking_id)
          if payment
            payment.update(status: 'FAILED')
            Rails.logger.info("Payment #{pesapal_transaction_tracking_id} marked as FAILED.")
          else
            Rails.logger.error("Payment not found for transaction #{pesapal_transaction_tracking_id}.")
          end
      
          # Respond with an error message
          render json: 'Payment failed', status: :unprocessable_entity
        else
          # Unknown or invalid status
        
          Rails.logger.error("Unknown status '#{status}' received for transaction #{pesapal_transaction_tracking_id}.")
      
          # Respond with an error message
          render json: 'Invalid status', status: :unprocessable_entity
        end
    end
      
  
    def pesapal_iframe
        order_request_payload = {
            id: params[:id],
            description: params[:description],
            amount: params[:amount],
            currency: params[:currency],
            callback_url: params[:callback_url],
            notification_id: session[:ipn_id],
            billing_address: params[:billing_address]
        }

        ipn_id = session[:ipn_id] #retrieve IPN ID from session
        auth_token = session[:auth_token] #retrieve token from session

        if auth_token.nil?
          render json: { error: 'Authorization token not found. Please authorize first.' }, status: :unauthorized
          if ipn_id.nil?
            render json: { error: 'IPN ID not found. Please register IPN first.' }, status: :unauthorized
          end 
        end

        
        
        response = HTTParty.post(SUBMIT_ORDER_REQUEST_URL, headers: PesapalService.authorization_header(auth_token), body: order_request_payload.to_json)
        if response.code == 200
          response_body = JSON.parse(response.body)
            render json: response_body
        # the redirect url in the response body is the URL to the Pesapal iframe
        else
          render json: { error: 'Failed to get Pesapal iframe URL' }, status: :unprocessable_entity
        end
       
    end
    
      
      
    
end
  