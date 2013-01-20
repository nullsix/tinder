require 'spec_helper'

#TODO: Since all the actions in this controller require you to be logged in, can we pull out the example that tests whether the user is logged in out to a module? This would allow us to to something like PiecesController acts_like_a UserOnlyResource
describe PiecesController do
  context "with no user logged in" do
    #TODO: DRY this up with use of a hash for the verb, action and data?
    describe "GET index" do
      it "redirects to root_path" do
        get :index
        should redirect_to(root_path)
      end
    end
  
    describe "PUT create" do
      it "redirects to root_path" do
        put :create
        should redirect_to(root_path)
      end
    end

    describe "GET new" do
      it "redirects to root_path" do
        get :new
        should redirect_to(root_path)
      end
    end

    context "where actions require a piece" do 
      before :all do
        @piece = create :piece
      end

      describe "GET show" do
        it "redirects to root_path" do
          get :show, id: @piece.id
          should redirect_to(root_path)
        end
      end

      describe "GET edit" do
        it "redirects to root_path" do
          get :edit, id: @piece.id
          should redirect_to(root_path)
        end
      end

      describe "PUT update" do
        it "redirects to root_path" do
          put :update, id: @piece.id
          should redirect_to(root_path)
        end
      end

      describe "DELETE destroy" do
        it "redirects to root_path" do
          delete :destroy, id: @piece.id
          should redirect_to(root_path)
        end
      end
    end
  end

  context "with a logged in user" do
    describe "GET new" do
      before :all do
        @user = FactoryGirl.create :user
        @piece = @user.pieces.build
      end

      before :each do
        session[:user_id] = @user.id
        get :new
      end

      it "renders the new layout" do
        should render_template(:new)
      end

      it "sets @piece to a Piece" do
        assigns(:piece).should be_a Piece
      end

      it "makes @piece a new piece" do
        assigns(:piece).should be_a_new_record
      end

      it "sets @version to a Version" do
        assigns(:version).should be_a Version
      end

      it "makes @version a new version" do
        assigns(:version).should be_a_new_record
      end
    end
  end
end
