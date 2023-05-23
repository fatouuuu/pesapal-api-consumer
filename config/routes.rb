Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  post '/pesapal/iframe', to: 'pesapal#pesapal_iframe'
  post '/pesapal/callback', to: 'pesapal#callback'
  # get '/pesapal/callback', to: 'pesapal#callback'
  post '/pesapal/authorization', to: 'pesapal#authorization'
  post '/pesapal/register_ipn', to: 'pesapal#register_ipn'


end
