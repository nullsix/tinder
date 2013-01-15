class ChangeVersionContentToTextInsteadOfString < ActiveRecord::Migration
  def up
    change_column :versions, :content, :text
  end

  def down
    change_column :versions, :content, :string
  end
end
