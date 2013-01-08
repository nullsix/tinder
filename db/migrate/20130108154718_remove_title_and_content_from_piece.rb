class RemoveTitleAndContentFromPiece < ActiveRecord::Migration
  def up
    remove_column :pieces, :title
    remove_column :pieces, :content
  end

  def down
    add_column :pieces, :content, :text
    add_column :pieces, :title, :string
  end
end
