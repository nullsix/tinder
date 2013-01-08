class Piece < ActiveRecord::Base
  attr_accessible :content, :title
  belongs_to :user
end
