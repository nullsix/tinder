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
  has_many :versions, dependent: :destroy, inverse_of: :piece

  accepts_nested_attributes_for :versions

  attr_accessible :user, :user_id, :versions, :current_version

  validates :user, presence: true

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
