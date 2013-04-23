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
  include Previewable

  belongs_to :piece, inverse_of: :versions
  has_one :draft, dependent: :destroy

  validates :title, length: { maximum: 255 }
  validates :number, numericality: { greater_than: 0 }

  validates :piece, presence: true

  def blurb
    preview content, BLURB_LENGTH
  end

  def short_title
    preview title, SHORT_TITLE_LENGTH
  end
end
