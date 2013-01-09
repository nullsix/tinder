class Piece < ActiveRecord::Base
  belongs_to :user
  has_many :versions, dependent: :destroy

  accepts_nested_attributes_for :versions

  attr_accessible :user

  def current_version
    versions.first
  end

  def current_version= version
    versions << version
  end
end
