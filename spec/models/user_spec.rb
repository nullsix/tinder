require 'spec_helper'

describe User do

  before { @user = create :user }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:pieces) }
  it { should respond_to(:provider) }
  it { should respond_to(:uid) }

  describe "::create_with_omniauth" do
    describe "creating a user" do

      let(:auth) { {"provider" => "test", "uid" => "test", "info" => { "name" => "test" }} }
      before {
        @user = User.create_with_omniauth(auth)
      }

      subject { @user }

      it "is valid" do
        should be_valid
      end

      it "has the right uid" do
        @user.uid.should eq(auth["uid"])
      end

      it "has the right provider" do
        @user.provider.should eq(auth["provider"])
      end

      it "has the right name" do
        @user.name.should eq(auth["info"]["name"])
      end

      it "is saved" do
        should_not be_a_new_record
      end
    end
  end
end

