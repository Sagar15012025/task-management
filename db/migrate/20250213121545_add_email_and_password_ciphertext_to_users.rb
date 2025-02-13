class AddEmailAndPasswordCiphertextToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :email_ciphertext, :text
    add_column :users, :password_ciphertext, :text
  end
end
