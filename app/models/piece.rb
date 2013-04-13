# == Schema Information
#
# Table name: pieces
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

class Piece < ActiveRecord::Base

  belongs_to :user, inverse_of: :pieces
  validates :user, presence: true

  has_many :versions, dependent: :destroy, inverse_of: :piece, order: "created_at ASC"
  has_many :drafts, through: :versions

  scope :last_modified_first, order("updated_at DESC")
  default_scope last_modified_first

  def current_version
    versions.last
  end

  def title
    current_version.title if !!current_version
  end

  def content
    current_version.content if !!current_version
  end

  def blurb
    current_version.blurb if !!current_version
  end

  def short_title
    current_version.short_title if !!current_version
  end
end
