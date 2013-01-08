class AddPieceIdToVersion < ActiveRecord::Migration
  def change
    add_column :versions, :piece_id, :integer
  end
end
