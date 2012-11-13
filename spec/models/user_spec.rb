require 'spec_helper'

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
      end
    end
  end
end

