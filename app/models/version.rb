class Version < ActiveRecord::Base
  belongs_to :piece, inverse_of: :versions
  attr_accessible :title, :content, :piece, :piece_id

  validates :title, length: { maximum: 255 }

  validates :piece, presence: true
end
