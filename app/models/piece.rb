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

  after_save :create_first_version
  before_update :check_for_new_version

  def current_version
    if current_version_changed?
      default_values
    end

    @current_version
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

  def changed?
    title_changed? || content_changed?
  end

  private
    def check_for_new_version
      if changed?
        version = current_version.dup
        version = set_version version, title, content
        version.save
      end
    end

    def title_changed?
      if current_version.nil?
        title.nil?
      else
        title != current_version.title
      end
    end

    def content_changed?
      if current_version.nil?
        content.nil?
      else 
        content != current_version.content
      end
    end

    def default_values
      if new_record?
        @title = "Untitled Piece" if @title.nil?
        @content = "" if @content.nil?

      else
        @current_version = versions.last
        if @current_version.nil?
          @title = "Untitled Piece"
          @content = ""

        else
          @title = @current_version.title
          @content = @current_version.content
        end
      end
    end

    def current_version_changed?
      @current_version != versions.last && !versions.last.nil?
    end

    def create_first_version
      version = versions.build
      version = set_version version, title, content
      version.save
    end

    def set_version(version, title, content)
      version.title = title
      version.content = content
      version.number = versions.count + 1
      version
    end
end
