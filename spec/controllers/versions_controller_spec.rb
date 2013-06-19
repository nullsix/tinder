require 'spec_helper'

describe VersionsController do
  before :each do
    @user = FactoryGirl.create :user, pieces_count: 0
    @piece = FactoryGirl.create :piece, versions_count: 0, user_id: @user.id
  end

  context "with no user logged in" do
    describe "GET index" do
      it "redirects to root_url" do
        get :index, piece_id: @piece.id
        should redirect_to root_url
      end
    end

    describe "GET show" do
      it "redirects to root_url" do
        version = FactoryGirl.create :version, piece_id: @piece.id
        get :show, piece_id: @piece.id, id: version.number

        should redirect_to root_url
      end
    end
  end

  context "with a non-existent piece" do
    before :each do
      session[:user_id] = @user.id
      @piece.id = -1
    end

    describe "GET index" do
      subject { get :index, piece_id: @piece.id }
      it { should redirect_to pieces_path }
    end

    describe "GET show" do
      subject { get :show, piece_id: @piece.id, id: -1 }
      it { should redirect_to pieces_path }
    end
  end

  context "with a non-existent version" do
    before :each do
      session[:user_id] = @user.id

      describe "GET show" do
        subject { get :show, piece_id: @piece.id, id: -1 }
        it { should redirect_to pieces_path }
      end
    end
  end

  context "with a logged in user" do
    before :each do
      session[:user_id] = @user.id

      @versions = []
      5.times do |i|
        @versions << FactoryGirl.create(:version, piece_id: @piece.id, title: i.to_s, number: (i+1).to_s)
      end
    end

    describe "GET index" do
      it "redirects to piece's history" do
        get :index, piece_id: @piece.id
        should redirect_to history_piece_path id: @piece.id
      end
    end

    describe "GET show" do
      before :each do
        @version_wanted = @versions.last
        get :show, piece_id: @piece.id, id: @version_wanted.number
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
