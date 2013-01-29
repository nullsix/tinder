require 'spec_helper'

describe PagesController do
  context "with no user logged in" do
    describe "GET index" do
      before :each do
        get :index
      end

      it "renders the #index view" do
        should render_template :index
      end

      it "does not assign @piece" do
        assigns(:piece).should be_nil
      end

      it "does not assign @version" do
        assigns(:version).should be_nil
      end
    end
  end

  context "with a logged in user" do
    before :all do
      @user = FactoryGirl.create :user, pieces_count: 0
    end

    describe "GET index" do
      before :each do
        session[:user_id] = @user.id
        get :index
      end

      it "renders the #index view" do
        should render_template :index
      end

      describe "@piece" do
        subject { assigns :piece }

        it "is a Piece" do
          should be_a Piece
        end

        it "is a new Piece" do
          should be_a_new_record
        end

        it "belongs to the logged in user" do
          subject.user.should eq @user
        end
      end

      describe "@version" do
        subject { assigns :version }

        it "is a Version" do
          should be_a Version
        end

        it "is a new Version" do
          should be_a_new_record
        end

        it "belongs to the piece being created" do
          subject.piece.should eq assigns(:piece)
        end
      end
    end
  end
end
