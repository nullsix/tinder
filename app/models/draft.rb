# == Schema Information
#
# Table name: drafts
#
#  id         :integer          not null, primary key
#  number     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  version_id :integer
#

class Draft < ActiveRecord::Base
  belongs_to :version

  def piece
    version.piece
  end
end
