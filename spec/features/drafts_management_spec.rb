feature "Drafts Management" do
  include PieceHelper

  subject { page }

  context "creating a draft" do
    background do
      login_with_oauth
      user = User.last
      @piece = create_piece user
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

        scenario "User sees the flash" do
          should have_content "Draft has been successfully created. You can now share this page's link with others and they will be able to read this draft!"
        end
      end

      context "not as the owner" do
        scenario "it redirects to your pieces_path" do
          otherbob = create_user "otherbob"
          otherpiece = create_piece(otherbob)
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
      @user = User.last
      @piece = create_piece @user, 1
      @draft = create_draft @piece.versions.last
    end

    context "while not logged in" do
      background do
        logout
        visit piece_draft_path piece_id: @piece, id: @draft.number
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
            @piece = create_piece @user
            @draft = create_draft @piece.versions.last
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
          @draft = create_draft @piece.versions.last
          visit piece_draft_path piece_id: @piece,
            id: @draft.number
        end

        it_behaves_like "no piece bar"
        it_behaves_like "non owner draft information"
      end
    end
  end

  context "viewing a piece's drafts" do
    scenario "redirects to history" do
      login_with_oauth
      user = User.last
      @piece = create_piece user

      visit piece_drafts_path @piece.id

      current_path.should == history_piece_path(id: @piece.id)
    end
  end
end
