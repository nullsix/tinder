class Version < ActiveRecord::Base
  belongs_to :piece, inverse_of: :versions
  attr_accessible :title, :content, :piece

  validates :piece, presence: true
end
