class Piece < ActiveRecord::Base
  belongs_to :user
  has_many :versions

  def current_version
    versions.first
  end

  def current_version= version
    versions << version
  end
end
