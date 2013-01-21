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
    before :all do
      @user = FactoryGirl.create :user
      @piece = @user.pieces.build
    end

    before :each do
      session[:user_id] = @user.id
    end

    describe "GET index" do
      before :each do
        get :index
      end

      it "renders the index layout" do
        should render_template(:index)
      end

      describe "@pieces" do
        subject{ assigns(:pieces) }
        it "is set" do
          should_not be_nil
        end

        it "is an array" do
          should be_a Array
        end

        it "is an array of Pieces" do
          subject.each { |p| p.should be_a Piece }
        end

        it "belongs to the logged in user" do
          subject.each { |p| p.user.should eq(@user) }
        end
      end
    end

    describe "GET new" do
      before :each do
        get :new
      end

      it "renders the new layout" do
        should render_template(:new)
      end

      describe "@piece" do
        subject { assigns(:piece) }

        it "is set" do
          should_not be_nil
        end

        it "is a Piece" do
          should be_a Piece
        end

        it "is a new Piece" do
          should be_a_new_record
        end

        it "belongs to the logged in user" do
          subject.user.should eq(@user)
        end
      end

      describe "@version" do
        subject { assigns(:version) }

        it "is set" do
          should_not be_nil
        end

        it "is a Version" do
          should be_a Version
        end

        it "is a new Version" do
          should be_a_new_record
        end
      end
    end
  end
end
