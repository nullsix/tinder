shared_examples "draft information" do
  scenario "shows draft information" do
    should have_content @piece.title
    should have_content @piece.content
    find(".created-time").text.should match /created .* ago/
  end
end

shared_examples "logged in draft information" do
  it_behaves_like "piece bar for version" do
    let(:piece) { @piece }
    let(:version) { @draft }
  end

  it_behaves_like "draft information"

  scenario "shows the right extra info" do
    should have_link "##{@draft.number}"
    should_not have_content "by #{@piece.user.name}"
  end
end

feature "Drafts Management" do
  include PieceHelper

  subject { page }

  context "creating a draft" do
    background do
      draft_create_piece
      create_draft
    end

    it_behaves_like "draft information"
  end

  context "viewing a draft" do
    context "while not logged in" do
      background do
        draft_create_piece
        create_draft
        logout
        visit piece_draft_path piece_id: @piece,
          id: @draft.number
      end

      it_behaves_like "no piece bar"
      it_behaves_like "draft information"

      scenario "page has the piece information" do
        should have_content "by #{@piece.user.name}"
      end
    end

    context "while logged in" do
      background do
        draft_create_piece
      end

      context "with one version" do
        background do
          create_draft
          visit piece_draft_path piece_id: @piece,
            id: @draft.number
        end

        it_behaves_like "logged in draft information"
      end

      context "with three versions" do
        background do
          draft_edit_piece
          draft_edit_piece
          create_draft
          visit piece_draft_path piece_id: @piece,
            id: @draft.number
        end

        it_behaves_like "logged in draft information"
      end
    end
  end

  private
    def draft_create_piece
      login_with_oauth
      visit pieces_path
      follow_link_and_create_piece
      @piece = Piece.last
    end

    def create_draft
      visit piece_path @piece
      all("a.make-draft-link").first.click
      @draft = @piece.current_version.draft
    end

    def draft_edit_piece
      visit edit_piece_path @piece
      expect_edit_piece_success("!", @piece.content*2)
    end
end
