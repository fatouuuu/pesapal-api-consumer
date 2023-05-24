# **API Integration with Pesapal API v3.0**

This is a guide on how to run the API, authenticate with Pesapal APIs, and get the Pesapal iframe URL using the API.

## **Table of Contents**

1. **[Introduction](#introduction)**
2. **[Prerequisites](#prerequisites)**
3. **[Setup](#setup)**
5. **[API Endpoints](#api-endpoints)**

## **Introduction**

This is a Ruby on Rails API that consumes Pesapal APIs. The API is able to get the Pesapal iframe URL as part of the API response. API Authentication is implemented using JWT Tokens. The API returns a JSON response with the Pesapal iframe URL as one of the properties after successful authentication and sending a request to the SubmitOrderRequest endpoint in the official Pesapal API V3.0.

## **Prerequisites**

- Ruby 2.7+
- Rails 6.0+
- A Pesapal Merchant Account (To obtain your consumer_key and consumer_secret from Pesapal)
- **[Postgresql](https://www.postgresql.org/download/)** (for the database)
- **[Postman](https://www.postman.com/downloads/)** (for testing the API)
- **[Ngrok](https://ngrok.com/download)** (for exposing your local server endpoints to the internet)
- **[Pesapal API Documentation](https://developer.pesapal.com/how-to-integrate/api-reference)** (for more information on the Pesapal API)

## **Setup**

1. Clone the repository to your local machine.
2. Navigate to the project directory.
3. Install the dependencies by running **`bundle install`**.
    This will install the following gems needed for the project:
    - `jwt`: A pure Ruby implementation of the RFC 7519 OAuth JSON Web Token (JWT) standard for authentication and authorization.
    - `httparty`: Ruby gem that provides a simple and elegant way to make HTTP requests for JSON APIs.
    - `dotenv-rails`: A zero-dependency module that loads environment variables from a .env file into ENV when the environment is bootstrapped.
4. Add your Pesapal credentials (consumer_key and consumer_secret) to a **`.env`** file. The file should look something like this:

    ```bash
    PESAPAL_CONSUMER_KEY="WJZ97D7dt/Pi3SB2tZUgYDhjKiM0dhG5"
    PESAPAL_CONSUMER_SECRET="1tmGLDVoePbcHOVJR1Q6hQcx/u4="
    ```

    > **🚧** Note: Be sure to replace the placeholders with your actual Pesapal credentials. Also, keep this file in your .gitignore to avoid committing your credentials.

5. Set up your database by running **`rails db:migrate`**.
6. Install ngrok on your local machine following the instructions **[here](https://ngrok.com/download)**.
7. To expose your local server to the internet using ngrok, run the following command in a separate terminal window:

    ```bash
    ngrok http 3000
    ```

    > Note: You need to replace 3000 with the port your Rails application is running on if it's different.

8. Copy the HTTPS Forwarding URL provided by ngrok, it should look something like **`https://<some-random-characters>.ngrok.io`**.
9. Update the **`config/environments/development.rb`** file with the HTTPS URL from ngrok as shown below:

        ```ruby
        Rails.application.configure do
        # ... other configurations
    
        config.hosts << "some-random-characters.ngrok.io"
        end
        ```

## **API Endpoints**

The API uses JWT Tokens for authentication. The `authorization` endpoint in the `PesapalController` is responsible for this. You need to send your Pesapal API keys (from your `.env` file) to this endpoint to get your authentication token. The authentication token is saved in sessions and is used in subsequent requests to other API endpoints.

### Authentication

To authenticate with the Pesapal API and obtain a JWT token, follow these steps:

Send a POST request to the /pesapal/authorization endpoint of the application.
Include your Pesapal credentials (consumer key and consumer secret) as parameters in the request body.
Upon successful authentication, the API will return a response containing a JWT token.
Once a response is sent back, the JWT token is saved in sessions and is used in subsequent requests to other API endpoints.

### Registering the IPN

Send a POST request to the /pesapal/register_ipn endpoint of the application.
Include the necessary parameters (such as the notification_url) in the request body.
Ensure that the notification_url parameter points to the endpoint in your application where you want to receive the IPN notifications.
Upon successful registration, the API will respond with a success message with details about the IPN registration.
Once a response is sent back, the IPN ID is saved in sessions and is used in subsequent requests to other API endpoints.

### Getting the Iframe URL

To obtain the Pesapal iframe URL, which allows users to make payments, follow these steps:

Send a POST request to the /pesapal/iframe endpoint of your application.
Include the required parameters (such as amount, description, type, etc.) in the request body.
Specify the necessary details related to the payment, such as the transaction amount and a description.
Ensure that you have a valid JWT token included in the Authorization header of the request, this is already handled by the API and will be retrieved when making request that require authentication.
Upon successful processing of the request, the API will respond with details of the transaction such as the order tracking ID, merchant reference and the Pesapal iframe URL, which you can use to embed the payment interface in your application.
