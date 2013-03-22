shared_examples "draft information" do
  scenario "shows draft information" do
    should have_content @piece.title
    should have_content @piece.content
    find(".created-time").text.should match /created .* ago/
  end
end

shared_examples "logged in draft information" do
  it_behaves_like "piece bar for draft" do
    let(:piece) { @piece }
    let(:draft) { @draft }
  end

  it_behaves_like "draft information"

  scenario "shows the right extra info" do
    should have_link "##{@draft.number}", href: piece_draft_path(piece_id: @piece, id: @draft.number)
    should_not have_content "by #{@piece.user.name}"
  end
end

shared_examples "non owner draft information" do
  it_behaves_like "draft information"

  scenario "shows the piece's user's name" do
    should have_content "by #{@piece.user.name}"
  end
end

module DraftHelper
  def create_user(name = "bobburger")
    user = User.new
    user.name = name
    user.save
    user
  end

  def create_piece(user)
    piece = Piece.new
    piece.user_id = user.id
    piece.save
    piece
  end

  def create_version(piece, title = Time.now.to_s, content = Time.now.to_s)
    version = Version.new
    version.piece_id = piece.id
    version.title = title
    version.content = content
    version.number = piece.versions.count + 1
    version.save
    version
  end

  def create_draft(version)
    draft = Draft.new
    draft.version_id = version.id
    draft.number = version.piece.drafts.count + 1
    draft.save
    draft
  end

  def ui_create_draft
    visit piece_path @piece
    all("a.make-draft-link").first.click
    @draft = @piece.current_version.draft
  end
end

feature "Drafts Management" do
  include DraftHelper

  subject { page }

  context "creating a draft" do
    background do
      login_with_oauth
      user = User.last
      @piece = create_piece user
      version = create_version @piece
    end

    context "while not logged in" do
      scenario "it redirects to root_path" do
        logout
        visit piece_path @piece
        current_path.should == root_path
      end
    end

    context "while logged in" do
      context "as the owner" do
        background do
          ui_create_draft
        end

        it_behaves_like "draft information"
      end

      context "not as the owner" do
        scenario "it redirects to your pieces_path" do
          otherbob = create_user "otherbob"
          otherpiece = create_piece(otherbob)
          otherversion = create_version(otherpiece)
          @piece = otherpiece
          visit piece_path @piece

          current_path.should == pieces_path
        end
      end
    end
  end

  context "viewing a draft" do
    background do
      login_with_oauth
      user = User.last
      @piece = create_piece user
      version = create_version @piece
      @draft = create_draft version
    end

    context "while not logged in" do
      background do
        logout
        visit piece_draft_path piece_id: @piece,
          id: @draft.number
      end

      it_behaves_like "no piece bar"
      it_behaves_like "non owner draft information"
    end

    context "while logged in" do
      context "as the owner" do
        context "with one version" do
          background do
            visit piece_draft_path piece_id: @piece,
              id: @draft.number
          end

          it_behaves_like "logged in draft information"
        end

        context "with three versions" do
          background do
            v2 = create_version @piece
            v3 = create_version @piece
            @draft = create_draft v3
            visit piece_draft_path piece_id: @piece,
              id: @draft.number
          end

          it_behaves_like "logged in draft information"
        end
      end
      
      context "as not the owner" do
        background do
          nonowner = create_user "nonowner"
          @piece = create_piece nonowner
          version = create_version @piece
          @draft = create_draft version
          visit piece_draft_path piece_id: @piece,
            id: @draft.number
        end

        it_behaves_like "no piece bar"
        it_behaves_like "non owner draft information"
      end
    end
  end
end
