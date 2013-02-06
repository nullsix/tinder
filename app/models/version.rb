class Version < ActiveRecord::Base
  belongs_to :piece, inverse_of: :versions
  attr_accessible :title, :content, :piece, :piece_id

  validates :title, length: { maximum: 255 }

  validates :piece, presence: true

  def blurb
    if content.length > 50
      "#{content[0..46]}..."
    else
      content
    end
  end
end
