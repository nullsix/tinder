# == Schema Information
#
# Table name: versions
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  piece_id   :integer
#  number     :integer
#

class Version < ActiveRecord::Base
  belongs_to :piece, inverse_of: :versions
  has_one :draft, dependent: :destroy


  validates :title, length: { maximum: 255 }
  validates :number, numericality: { greater_than: 0 }

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
