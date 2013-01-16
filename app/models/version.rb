class Version < ActiveRecord::Base
  belongs_to :piece, inverse_of: :versions
  attr_accessible :title, :content, :piece

  validates :title, presence: true, length: { maximum: 255 }
  validates :content, presence: true

  # validates :piece, presence: true
end
