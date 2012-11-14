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

    def self.create_user_folders(id)
      data_path = Rails.root.join("data")
      FileUtils.mkdir_p(File.join(data_path, id.to_s))
    end

    user = create_the_user(auth)
    create_user_folders(auth["uid"])
    user
  end
end
