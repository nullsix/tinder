class AddNumberToVersion < ActiveRecord::Migration
  class Version < ActiveRecord::Base
  end

  def up
    add_column :versions, :number, :int

    Version.reset_column_information
    Piece.all.each do |piece|
      piece.versions.each.with_index do |version, index|
        version.number = index + 1
        version.save
      end
    end
  end

  def down
    remove_column :versions, :number
  end
end
