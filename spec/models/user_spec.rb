require 'spec_helper'

describe User do

  describe "instance methods" do
    let(:user) { build_stubbed :user }

    subject { user }

    it { should respond_to(:name) }
    it { should respond_to(:pieces) }
    it { should respond_to(:provider) }
    it { should respond_to(:uid) }
  end

  describe "::create_with_omniauth" do
    describe "creating a user" do

      let(:auth) { {"provider" => "test", "uid" => "test", "info" => { "name" => "test" }} }
      let(:user) { User.create_with_omniauth(auth) }

      subject { user }

      it { should be_valid }

      it "has the right uid" do
        subject.uid.should ==(auth["uid"])
      end

      it "has the right provider" do
        subject.provider.should ==(auth["provider"])
      end

      it "has the right name" do
        subject.name.should ==(auth["info"]["name"])
      end

      it "is saved" do
        should_not be_a_new_record
      end
    end
  end
end

