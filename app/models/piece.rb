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
  include Previewable

  attr_writer :content

  belongs_to :user, inverse_of: :pieces
  validates :user, presence: true

  has_many :versions, dependent: :destroy, inverse_of: :piece,
    order: "created_at ASC"
  has_many :drafts, through: :versions

  scope :last_modified_first, order("updated_at DESC")
  default_scope last_modified_first

  def current_version
    versions.last
  end

  def title
    @title ||= current_version.title if !current_version.nil?
  end

  def title=(value)
    if value.empty?
      @title = "Untitled Piece"
    else
      @title = value
    end
  end

  def content
    @content ||= current_version.content if !current_version.nil?
  end

  def blurb
    preview content, BLURB_LENGTH
  end

  def short_title
    preview title, SHORT_TITLE_LENGTH
  end
end
