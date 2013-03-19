class RemovePieceIdFromDrafts < ActiveRecord::Migration
  class Draft < ActiveRecord::Base
  end

  def up
    remove_column :drafts, :piece_id
  end

  def down
    add_column :drafts, :piece_id, :integer
  end
end
