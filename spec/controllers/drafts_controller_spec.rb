require 'spec_helper'

describe DraftsController, "POST create" do
  before :each do
    @user = FactoryGirl.create :user, pieces_count: 1
    session[:user_id] = @user.id
    @user.reload
    @piece = @user.pieces.first
    @post_new = Proc.new { post :create, piece_id: @piece }
  end

  it "creates a new draft" do
    expect{ @post_new.call }.to change(Draft, :count).by 1
  end

  it "gives draft the right number" do
    expected_number = @piece.drafts.count + 1
    @post_new.call
    Draft.last.number.should eq expected_number
  end

  it "redirects to show the draft" do
    @post_new.call
    should redirect_to piece_draft_path piece_id: @piece, id: Draft.last.number
  end

  context "with an invalid piece" do
    it "redirects to pieces path" do
      post :create, piece_id: -1
      should redirect_to pieces_path
    end
  end

  context "while not logged in" do
    before :each do
      session[:user_id] = nil
      @post_create = Proc.new { post :create, piece_id: @piece }
    end

    it "redirects to root path" do
      @post_create.call
      should redirect_to root_url
    end

    it "doesn't create a draft" do
      expect{ @post_create.call }.not_to change(Draft, :count)
    end
  end

  describe "with another user logged in" do
    it "redirects to their pieces path" do
      other_user = FactoryGirl.create :user, pieces_count: 0
      session[:user_id] = other_user.id
      post :create, piece_id: @piece
      should redirect_to pieces_path
    end
  end

end

describe DraftsController, "GET show" do
  before :each do
    @piece = FactoryGirl.create :piece
    @version = FactoryGirl.create :version, piece: @piece
    @draft = FactoryGirl.create :draft, version: @version
    get :show, id: @draft.number, piece_id: @piece
  end

  it "renders the #show view" do
    should render_template :show
  end

  specify "assigns @draft" do
    assigns(:draft).should be_a Draft
  end

  context "with an invalid piece" do
    it "redirects to pieces path" do
      get :show, id: @draft, piece_id: -1
      should redirect_to pieces_path
    end
  end

  context "with an invalid draft" do
    it "redirects to pieces path" do
      get :show, id: -1, piece_id: @piece
      should redirect_to piece_path @piece
    end
  end
end

describe DraftsController, "GET index" do
  before :each do
    user = create_user
    @piece = create_piece user
    @draft = create_draft @piece.versions.last
    get :index, piece_id: @piece.id, id: @draft.number
  end

  it "redirects to piece history" do
    should redirect_to history_piece_path id: @piece
  end
end
