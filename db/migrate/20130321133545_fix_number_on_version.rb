class FixNumberOnVersion < ActiveRecord::Migration
  class Version < ActiveRecord::Base
  end

  def up
    ActiveRecord::Base.record_timestamps = false

    Piece.all.each do |piece|
      piece.versions.sort_by(&:created_at).each.with_index do |version, index|
        version.number = index + 1
        version.save
      end
    end
  end

  def down
    # Can't really undo this.
  end
end
