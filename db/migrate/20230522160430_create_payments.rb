class CreatePayments < ActiveRecord::Migration[7.0]
  def change
    create_table :payments do |t|
      t.string :pesapal_transaction_tracking_id
      t.string :merchant_reference
      t.string :status

      t.timestamps
    end
  end
end
