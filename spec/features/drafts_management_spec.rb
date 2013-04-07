feature "Drafts Management" do
  include PieceHelper

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
          gui_create_draft
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
