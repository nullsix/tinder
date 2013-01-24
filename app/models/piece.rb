class Piece < ActiveRecord::Base
  belongs_to :user, inverse_of: :pieces
  has_many :versions, dependent: :destroy, inverse_of: :piece

  accepts_nested_attributes_for :versions

  attr_accessible :user, :user_id, :versions, :current_version

  validates :user, presence: true

  def current_version
    versions.last
  end
end
