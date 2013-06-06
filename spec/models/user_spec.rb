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

  let(:user) { FactoryGirl.build_stubbed :user }

  subject { user }

  describe "#name" do
    it_behaves_like "instance method" do
      let(:instance) { user }
      let(:method) { :name }
    end
  end

  describe "#pieces" do
    it_behaves_like "instance method" do
      let(:instance) { user }
      let(:method) { :pieces }
    end
  end

  describe "#provider" do
    it_behaves_like "instance method" do
      let(:instance) { user }
      let(:method) { :provider }
    end
  end

  describe "#uid" do
    it_behaves_like "instance method" do
      let(:instance) { user }
      let(:method) { :uid }
    end
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
