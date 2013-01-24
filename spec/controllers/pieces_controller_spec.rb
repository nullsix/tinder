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
      @user = FactoryGirl.create(:user, pieces_count: 0)
      @piece = @user.pieces.create
    end

    before :each do
      session[:user_id] = @user.id
    end

    describe "GET index" do
      before :each do
        get :index
      end

      it "renders the #index view" do
        should render_template(:index)
      end

      describe "@pieces" do
        subject{ assigns(:pieces) }

        it "is an array of Pieces" do
          should eq([@piece])
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

        it "is a Version" do
          should be_a Version
        end

        it "is a new Version" do
          should be_a_new_record
        end

        it "belongs to the piece being created" do
          subject.piece.should eq(assigns(:piece))
        end
      end
    end

    describe "POST create" do
      before :each do
        @piece_attr = FactoryGirl.attributes_for(:piece, user_id: @user)
        @version_attr = FactoryGirl.attributes_for(:version, piece_id: @piece)
        @valid_create = Proc.new{ post :create, piece: @piece_attr, version: @version_attr }
      end

      context "with a valid version" do
        it "creates a new piece" do
          expect { @valid_create.call }.to change(Piece, :count).by(1)
        end

        it "creates a new version" do
          expect { @valid_create.call }.to change(Version, :count).by(1)
        end

        it "redirects to the piece just created" do
          @valid_create.call

          should redirect_to Piece.last
        end
      end

      context "with an invalid version" do
        before :each do
          @invalid_version_attr = FactoryGirl.attributes_for(:invalid_version, piece_id: @piece)
          @invalid_create = Proc.new{ post :create, piece: @piece_attr, version: @invalid_version_attr }
        end

        it "does not create a new piece" do
          expect { @invalid_create.call }.to_not change(Piece, :count)
        end
        
        it "does not create a new version" do
          expect { @invalid_create.call }.to_not change(Version, :count)
        end

        it "renders the #new view" do
          @invalid_create.call

          should render_template :new
        end
      end
    end

    describe "GET edit" do
      before :each do
        get :edit, id: @piece
      end

      it "renders the #edit view" do
        should render_template(:edit)
      end

      it "assigns the requested piece to @piece" do
        assigns(:piece).should eq(@piece)
      end

      it "assigns the piece's current version to @version" do
        assigns(:version).should eq(@piece.current_version)
      end
    end

    describe "PUT update" do
      context "with a valid piece" do
        context "with a valid version" do
          it "creates a new version"
        end

        context "with an invalid version" do
          it "does not create a new version"
        end
      end
      context "with an invalid piece" do
        it "does not create a new version"
      end
    end

    describe "GET show" do
      before :each do
        get :show, id: @piece
      end

      it "renders the #show view" do
        should render_template(:show)
      end

      it "assigns the requested piece to @piece" do
        assigns(:piece).should eq(@piece)
      end
    end
  end
end
