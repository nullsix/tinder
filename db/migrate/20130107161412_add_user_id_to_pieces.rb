class AddUserIdToPieces < ActiveRecord::Migration
  def change
    add_column :pieces, :user_id, :integer
  end
end
