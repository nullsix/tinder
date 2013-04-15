class CreateDrafts < ActiveRecord::Migration
  def change
    create_table :drafts do |t|
      t.integer :number
      t.references :piece

      t.timestamps
    end
    add_index :drafts, :piece_id
  end
end
