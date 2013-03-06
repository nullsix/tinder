# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  name       :string(255)
#  provider   :string(255)
#  uid        :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class User < ActiveRecord::Base
  has_many :pieces, inverse_of: :user
  accepts_nested_attributes_for :pieces

  attr_accessible :provider, :uid, :name, :pieces

  def self.create_with_omniauth(auth)
    def self.create_the_user(auth)
      create! do |user|
        user.uid = auth["uid"]
        user.provider = auth["provider"]
        user.name = auth["info"]["name"]
      end
    end

    create_the_user(auth)
  end
end
