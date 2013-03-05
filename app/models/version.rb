class Version < ActiveRecord::Base
  belongs_to :piece, inverse_of: :versions
  attr_accessible :title, :content, :piece, :piece_id

  validates :title, length: { maximum: 255 }

  validates :piece, presence: true

  def blurb
    content_length = 50
    if content.length > content_length
      "#{content[0..(content_length-4)]}..."
    else
      content
    end
  end

  def short_title
    title_length = 30
    if title.length > title_length
      "#{title[0..(title_length-4)]}..."
    else
      title
    end
  end
end
