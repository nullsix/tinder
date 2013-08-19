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

  belongs_to :user, inverse_of: :pieces
  validates :user, presence: true

  validates :title, length: { maximum: 255 }

  has_many :versions, -> { order(created_at: :asc) },
    dependent: :destroy, inverse_of: :piece
  has_many :drafts, through: :versions

  scope :last_modified_first, -> { order("updated_at DESC") }
  default_scope { last_modified_first }

  after_save :create_first_version
  before_update :check_for_new_version
  after_find :default_values_for_existing_piece

  def current_version
    versions.last
  end

  def title
    default_values_for_empty_piece

    @title
  end

  def title=(value)
    if value.nil? || value.empty? #TODO: This should be blank?
      @title = "Untitled Piece"

    else
      @title = value
    end
  end

  def short_title
    preview title, SHORT_TITLE_LENGTH
  end

  def content
    default_values_for_empty_piece

    @content
  end

  attr_writer :content

  def blurb
    preview content, BLURB_LENGTH
  end

  def changed?
    title_changed? || content_changed?
  end

  def create_draft(version = current_version)
    return false if version.draft

    draft = Draft.new
    draft.version = version

    if drafts.empty?
      draft.number = 1
    else
      draft.number = drafts.last.number + 1
    end

    return draft.save
  end

  private
    def create_first_version
      return true unless new_record? || versions.count.zero?
      version = versions.build
      version.title = title
      version.content = content
      version.number = 1
      version.save
    end

    def check_for_new_version
      if changed?
        version = current_version.dup
        version.title = title
        version.content = content
        version.number = current_version.number + 1
        version.save
        self.touch
      end
    end

    def default_values_for_empty_piece
      @title = "Untitled Piece" if @title.nil?
      @content = "" if @content.nil?
    end

    def title_changed?
      return true if current_version.nil?

      @title != current_version.title
    end

    def content_changed?
      return true if current_version.nil?

      @content != current_version.content
    end

    def default_values_for_existing_piece
      if !new_record? && current_version.nil?
        @title = "Untitled Piece"
        @content = ""

      else
        @title = current_version.title
        @content = current_version.content
      end
    end
end
