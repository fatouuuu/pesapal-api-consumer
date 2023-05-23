class Payment < ApplicationRecord
    validates :pesapal_transaction_tracking_id, presence: true
    validates :merchant_reference, presence: true
    validates :status, presence: true
  
    
end
  