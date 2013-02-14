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

      @versions = []
      5.times do |i|
        @versions << FactoryGirl.create(:version, piece_id: @piece.id, title: i.to_s)
      end
    end

    describe "GET index" do
      before :each do
        get :index, piece_id: @piece.id
      end

      specify "@versions is set" do
        assigns(:versions).should eq @versions.reverse
      end

      specify "@piece is set" do
        assigns(:piece).should eq @piece
      end
    end

    describe "GET show" do
      before :each do
        @version_wanted = @versions.last
        visit piece_version_path piece_id: @piece.id, id: @version_wanted.id

        get :show, piece_id: @piece.id, id: @version_wanted.id
      end

      specify "@version is set" do
        assigns(:version).should eq @version_wanted
      end

      specify "@piece is set" do
        assigns(:piece).should eq @piece
      end
    end
  end
end
