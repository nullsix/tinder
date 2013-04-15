class AddVersionToDraft < ActiveRecord::Migration
  class Draft < ActiveRecord::Base
  end
  def change
    add_column :drafts, :version_id, :integer
  end
end
