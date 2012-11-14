require 'spec_helper'
require 'fakefs/spec_helpers'

describe User do

  before { @user = User.new }

  subject { @user }

  describe "a blank user" do
    it { should respond_to(:name) }
    it { should respond_to(:provider) }
    it { should respond_to(:uid) }
  end

  describe "self" do
    describe ".create_with_omniauth" do
      describe "creating a user" do
        include FakeFS::SpecHelpers 

        let(:auth) { {"provider" => :test, "uid" => :test, "info" => { "name" => "test" }} }
        before {
          @user = User.create_with_omniauth(auth)
        }

        subject { @user }

        it "should be valid" do
          should be_valid
        end

        it "should have the right uid" do
          @user.uid.should eq(auth["uid"])
        end

        it "should have the right provider" do
          @user.provider.should eq(auth["provider"])
        end

        it "should have the right name" do
          @user.name.should eq(auth["info"]["name"])
        end

        it "should create a user directory" do
          def user_dir
            data_path = Rails.root.join("data")
            user_path = File.join(data_path, auth["uid"].to_s)
            File.directory?(user_path)
          end

          user_dir.should be_true
        end
      end
    end
  end
end

