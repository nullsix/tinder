class CreateVersions < ActiveRecord::Migration
  def change
    create_table :versions do |t|
      t.string :title
      t.string :content

      t.timestamps
    end
  end
end
