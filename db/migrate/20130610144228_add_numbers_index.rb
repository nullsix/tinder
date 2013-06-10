class AddNumbersIndex < ActiveRecord::Migration
  def up
    add_index :versions, :number
    add_index :drafts, :number
  end

  def down
    remove_index :versions, :number
    remove_index :drafts, :number
  end
end
