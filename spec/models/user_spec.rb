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

require 'spec_helper'

describe User do

  it "has a valid factory" do
    FactoryGirl.build_stubbed(:user).should be_valid
  end

  describe "instance methods" do
    before :each do
      @user = build_stubbed :user
    end

    subject { @user }

    it { should respond_to :name }
    it { should respond_to :pieces }
    it { should respond_to :provider }
    it { should respond_to :uid }
  end

  describe "::create_with_omniauth" do
    describe "creating a user" do

      before :all do
        @auth = {"provider" => "test", "uid" => "test", "info" => { "name" => "test" }}
        @user = User.create_with_omniauth @auth
      end

      subject { @user }

      it { should be_valid }

      it "has the right uid" do
        subject.uid.should == @auth["uid"]
      end

      it "has the right provider" do
        subject.provider.should == @auth["provider"]
      end

      it "has the right name" do
        subject.name.should == @auth["info"]["name"]
      end

      it "is saved" do
        should_not be_a_new_record
      end
    end
  end
end
