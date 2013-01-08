class User < ActiveRecord::Base
  attr_accessible :name, :provider, :uid

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
