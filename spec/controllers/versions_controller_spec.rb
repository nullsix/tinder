require 'spec_helper'

describe VersionsController do
  before :all do
    @user = FactoryGirl.create :user, pieces_count: 0
    @piece = FactoryGirl.create :piece, versions_count: 0, user_id: @user.id
  end

  context "with no user logged in" do
    methods = [
      { get: :index  }
    ]

    methods.each do |m|
      m.each do |verb, action|
        describe "#{verb.upcase} #{action}" do
          it "redirects to root_url" do
            self.send verb, action, piece_id: @piece.id
            should redirect_to root_url
          end
        end
      end
    end
  end

  context "with a logged in user" do
    before :each do
      session[:user_id] = @user.id
    end

    describe "GET index" do
      before :each do

        @versions = []
        5.times do |i|
          @versions << FactoryGirl.create(:version, piece_id: @piece.id, title: i.to_s)

          get :index, piece_id: @piece.id
        end
      end

      specify "@versions is set" do
        assigns(:versions).should eq @versions.reverse
      end

      specify "@piece is set" do
        assigns(:piece).should eq @piece
      end
    end
  end
end
