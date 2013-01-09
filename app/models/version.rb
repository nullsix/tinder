class Version < ActiveRecord::Base
  belongs_to :piece

  attr_accessible :title, :content, :piece
end
