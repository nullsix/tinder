class User < ActiveRecord::Base
  has_many :pieces
  accepts_nested_attributes_for :pieces

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
