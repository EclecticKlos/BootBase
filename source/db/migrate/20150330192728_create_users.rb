class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string  :username
      t.string  :auth_token
      t.integer :github_id
    end
  end
end
