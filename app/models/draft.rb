# == Schema Information
#
# Table name: drafts
#
#  id         :integer          not null, primary key
#  number     :integer
#  piece_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Draft < ActiveRecord::Base
  belongs_to :piece
  attr_accessible :number
end
