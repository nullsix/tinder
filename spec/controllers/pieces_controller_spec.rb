require 'spec_helper'

shared_examples "requires user" do
  context "with no user logged in" do
    it "redirects to root_url" do
      if needs_piece
        piece = FactoryGirl.create :piece
        self.send verb, action, id: piece.id
      else
        self.send verb, action
      end

      should redirect_to root_url
    end
  end
end

shared_examples "requires owner" do
  context "with a user logged in" do
    context "who is not the owner" do
      include_context "is not owner"

      it "redirects to the logged in user's pieces" do
        if needs_piece
          piece =
            FactoryGirl.create :piece, user: user, versions_count: 1
          self.send verb, action, id: piece.id
        else
          self.send verb, action
        end

        should redirect_to pieces_url
      end
    end
  end
end

shared_context "users" do
  let(:user) { FactoryGirl.create :user, name: "Bob", pieces_count: 0 }
  let(:other_user) { FactoryGirl.create :user, name: "Other", pieces_count: 0 }
end

shared_context "is owner" do
  include_context "users"
  before :each do
    session[:user_id] = user.id
  end
end

shared_context "is not owner" do
  include_context "users"
  before :each do
    session[:user_id] = other_user.id
  end
end

shared_context "with owner's pieces" do
  include_context "is owner"

  let!(:first_piece) do
    FactoryGirl.create :piece, user: user, versions_count: 1
  end

  let!(:second_piece) do
    FactoryGirl.create :piece, user: user, versions_count: 1
  end

  let!(:user_pieces) { user.pieces.last_modified_first }

  let!(:other_pieces) do
    op = []
    5.times do
      op <<
        FactoryGirl.create(:piece, user: other_user, versions_count: 1)
    end
    op
  end
end

shared_examples "assigns @piece" do
  describe "@piece" do
    it "is a Piece" do
      assigns(:piece).should be_a Piece
    end

    it "belongs to the logged in user" do
      assigns(:piece).user.should eq user
    end
  end
end

shared_examples "assigns @version" do
  describe "@version" do
    it "is a Version" do
      assigns(:version).should be_a Version
    end

    it "belongs to the piece being created" do
      assigns(:version).piece.should eq assigns(:piece)
    end
  end
end

shared_examples "creates new piece" do
  it "creates a new piece" do
    expect { @valid_create.call }.to change(Piece, :count).by 1
  end

  it "creates a new version" do
    expect { @valid_create.call }.to change(Version, :count).by 1
  end

  it "redirects to the piece just created" do
    @valid_create.call

    should redirect_to Piece.first
  end

  it "has the correct version number" do
    @valid_create.call
    Version.last.number == Piece.first.versions.count
  end
end

describe PiecesController, "GET index" do
  it_behaves_like "requires user" do
    let(:verb) { "get" }
    let(:action) { "new" }
    let(:needs_piece) { false }
  end

  context "with owner logged in" do
    include_context "with owner's pieces"

    before :each do
      get :index
    end

    specify "@pieces is the user's pieces" do
      assigns(:pieces).should eq [second_piece, first_piece]
    end

    it "renders the #index view" do
      should render_template :index
    end
  end
end

describe PiecesController, "GET new" do
  it_behaves_like "requires user" do
    let(:verb) { "get" }
    let(:action) { "new" }
    let(:needs_piece) { false }
  end

  context "with owner logged in" do
    include_context "is owner"

    before :each do
      get :new
    end

    specify "@piece is a new Piece" do
      assigns(:piece).should be_a_new_record
    end

    specify "@version is a new Version" do
      assigns(:version).should be_a_new_record
    end

    it "renders the #new view" do
      should render_template :new
    end
  end
end

describe PiecesController, "POST create" do
  it_behaves_like "requires user" do
    let(:verb) { "post" }
    let(:action) { "create" }
    let(:needs_piece) { false }
  end

  context "with a logged in user" do
    before :each do
      @piece_attr = FactoryGirl.attributes_for :piece, user: user
    end

    context "who is the owner" do
      include_context "is owner"

      before :each do
        @piece = FactoryGirl.create :piece, user: user
      end

      context "with a valid version" do
        context "with an empty title" do
          before :each do
            @version_attr =
              FactoryGirl.attributes_for :version,
                piece_id: @piece,
                title: ""
            @valid_create =
              Proc.new {
                post :create, piece: @piece_attr, version: @version_attr
              }
          end

          it_behaves_like "creates new piece"

          it "has a default title" do
            @valid_create.call

            version = Version.last
            version.title.should match /Untitled Piece/
          end
        end

        context "with a non-empty title" do
          before :each do
            @version_attr =
              FactoryGirl.attributes_for :version, piece_id: @piece
            @valid_create =
              Proc.new {
                post :create, piece: @piece_attr, version: @version_attr
              }
          end

          it_behaves_like "creates new piece"
        end
      end

      context "with an invalid version" do
        before :each do
          @invalid_version_attr =
            FactoryGirl.attributes_for :invalid_version, piece_id: @piece
          @invalid_create =
            Proc.new {
              post :create, piece: @piece_attr, version: @invalid_version_attr
            }
        end

        it "does not create a new piece" do
          expect { @invalid_create.call }.to_not change Piece, :count
        end
        
        it "does not create a new version" do
          expect { @invalid_create.call }.to_not change Version, :count
        end

        context "after the call" do
          before :each do
            @invalid_create.call
          end

          it_behaves_like "assigns @piece"
          it_behaves_like "assigns @version"

          specify "@version has an error message" do
            assigns(:version).errors.should_not be_empty
          end

          it "renders the #new view" do
            should render_template :new
          end
        end
      end
    end
  end
end

describe PiecesController, "GET show" do
  let(:verb) { "get" }
  let(:action) { "show" }
  let(:needs_piece) { true }

  it_behaves_like "requires user"

  it_behaves_like "requires owner"

  context "with a logged in user" do
    context "who is the owner" do
      include_context "with owner's pieces"

      before :each do
        get :show, id: first_piece
      end

      it "assigns the requested piece to @piece" do
        assigns(:piece).should eq first_piece
      end

      it "renders the #show view" do
        should render_template :show
      end
    end
  end
end

describe PiecesController, "GET edit" do
  let(:verb) { "get" }
  let(:action) { "edit" }
  let(:needs_piece) { true }

  it_behaves_like "requires user"
  it_behaves_like "requires owner"

  context "with owner logged in" do
    include_context "with owner's pieces"

    before :each do
      get :edit, id: first_piece
    end

    it "assigns the requested piece to @piece" do
      assigns(:piece).should eq first_piece
    end

    it "assigns the piece's current version to @version" do
      assigns(:version).should eq first_piece.current_version
    end

    it "renders the #edit view" do
      should render_template :edit
    end
  end
end

describe PiecesController, "PUT update" do
  let(:verb) { "put" }
  let(:action) { "update" }
  let(:needs_piece) { true }

  it_behaves_like "requires user"

  it_behaves_like "requires owner"

  describe "with a user logged in" do
    context "who is the owner" do
      include_context "with owner's pieces"

      before :each do
        @piece_attr =
          FactoryGirl.attributes_for(
            :piece, piece_id: first_piece, user: user
          )
      end

      context "with a valid piece" do
        context "with an unchanged version" do
          before :each do
            @unchanged_version_attr = 
              FactoryGirl.attributes_for(
                :version,
                piece_id: first_piece,
                title: first_piece.current_version.title,
                content: first_piece.current_version.content
              )
            @unchanged_update = Proc.new {
              put :update,
                id: first_piece.id,
                piece: @piece_attr,
                version: @unchanged_version_attr
            }
          end

          it "doesn't create a new version" do
            expect{
              @unchanged_update.call
            }.not_to change(Version, :count)
          end

          it "redirects to the piece" do
            @unchanged_update.call
            should redirect_to first_piece
          end
        end

        context "with a changed version" do
          before :each do
            @changed_version_attr =
              FactoryGirl.attributes_for(
                :version,
                piece_id: first_piece,
                title: "I like pie.",
                content: "La-de-da-de-da"
              )
            @changed_update = Proc.new {
              put :update,
                id: first_piece.id,
                piece: @piece_attr,
                version: @changed_version_attr
            }
          end

          it "creates a new version" do
            expect { @changed_update.call }.to change(Version, :count).by 1
          end

          it "associates the new version to the existing piece" do
            expect {
              @changed_update.call
              first_piece.reload
            }.to change(first_piece.versions, :count).by 1
          end

          it "has the correct version number" do
            @changed_update.call
            first_piece.current_version.number == first_piece.versions.count
          end

          context "after the call" do
            before :each do
              @changed_update.call
            end

            it "locates the requested piece" do
              assigns(:piece).should eq first_piece
            end

            specify "locates the requested version" do
              assigns(:version).should eq Version.last
            end

            it "creates the version with the given attributes" do
              first_piece.reload
              first_piece.versions.last.title.should eq "I like pie."
              first_piece.versions.last.content.should eq "La-de-da-de-da"
            end

            it "redirects to the piece" do
              should redirect_to first_piece
            end
          end
        end

        context "with an invalid version" do
          before :each do
            @invalid_version_attr =
              FactoryGirl.attributes_for(
                :invalid_version,
                piece_id: first_piece,
                content: "La-de-da-de-da"
              )
            @invalid_update =
              Proc.new {
                put :update,
                  id: first_piece.id,
                  piece: @piece_attr,
                  version: @invalid_version_attr
              }
          end

          it "does not create a new version" do
            expect{ @invalid_update.call }.not_to change Version, :count
          end

          context "after the call" do
            before :each do
              @invalid_update.call
            end

            it "locates the requested piece" do
              assigns(:piece).should eq first_piece
            end

            it_behaves_like "assigns @version"

            it "does not create a Version with the attributes" do
              piece = Piece.find assigns(:piece).id
              piece.versions.last.content.should_not eq @invalid_version_attr[:content]
            end

            it "re-renders the #edit view" do
              should render_template :edit
            end
          end
        end
      end

      context "with an invalid piece" do
        it "does not create a new version" do
          expect{
            put :update, id: -1
          }.not_to change(Version, :count)
        end
      end
    end
  end
end

describe PiecesController, "DELETE destroy" do
  let(:verb) { "delete" }
  let(:action) { "destroy" }
  let(:needs_piece) { true }

  it_behaves_like "requires user"

  it_behaves_like "requires owner"

  context "with a logged in user" do
    context "who is the owner" do
      include_context "with owner's pieces"

      before :each do
        @valid_destroy = Proc.new{ delete :destroy, id: first_piece.id }
      end

      it "deletes the piece" do
        expect{ @valid_destroy.call }.to change(Piece, :count).by -1
      end

      it "deletes the associated versions" do
        expect { @valid_destroy.call }.to change(Version, :count).
          by -1*first_piece.versions.length
      end

      it "redirects to the pieces#index" do
        @valid_destroy.call
        should redirect_to pieces_url
      end
    end
  end
end

describe PiecesController, "GET history" do
  shared_context "multiple drafts" do
    before :each do
      # Create drafts for the even pieces
      @drafts = []
      piece.versions.each.with_index do |v, i|
        @drafts << create_draft(v) if i.even?
      end

      get :history, id: piece.id
    end
  end

  let(:piece) { FactoryGirl.create :piece, user: user, versions_count: 5 }

  context "with no user logged in" do
    include_context "users"
    include_context "multiple drafts"

    specify "assigns @history" do
      assigns(:history).should be
    end

    specify "@history is the piece's drafts" do
      assigns(:history).should == @drafts
    end

    it "renders the history view" do
      should render_template :history
    end
  end

  context "with a user logged in" do
    context "who is the owner" do
      include_context "is owner"

      before :each do
        @history = piece.versions

        piece.versions.each.with_index do |v, i|
            @history[i] = create_draft(v) if i.even?
        end

        get :history, id: piece.id
      end

      specify "assigns @history" do
        assigns(:history).should be
      end

      specify "@history is the users versions and drafts" do
        assigns(:history).should == @history
      end

      it "renders the history view" do
        should render_template :history
      end
    end

    context "who isn't the owner" do
      include_context "is not owner"
      include_context "multiple drafts"

      specify "assigns @history" do
        assigns(:history).should be
      end

      specify "@history is the piece's drafts" do
        assigns(:history).should == @drafts
      end

      it "renders the history view" do
        should render_template :history
      end
    end
  end
end
