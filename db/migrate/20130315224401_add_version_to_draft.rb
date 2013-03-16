class AddVersionToDraft < ActiveRecord::Migration
  def change
    add_column :drafts, :version_id, :integer
  end
end
