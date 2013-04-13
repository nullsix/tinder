feature "Pieces Management" do
  include PieceHelper

  background do
    login_with_oauth
  end

  subject { page }

  context "from the root path" do
    background { visit root_path }
    it_behaves_like "a user creating a piece"
  end

  context "when creating pieces with multiple lines" do
    require 'faker'

    background do
      visit new_piece_path
    end

    [1,3].each do |num|
      scenario "User sees #{num} lines rendered properly" do
        expect_create_piece_success "A good title", Faker::Lorem.sentences(num).join("\n\n")
        within '#content' do
          should have_css "p", count: num
        end
      end
    end
  end

  context "from the Pieces path" do
    background { visit pieces_path }

    it_behaves_like "piece bar"

    context "with no pieces" do
      scenario "User sees they have no pieces" do
        should have_content "your pieces"
        should have_content "You have no pieces."
      end
    end

    context "with many pieces" do
      before :each do
        @pieces_count = 5
        @pieces_count.times do |i|
          visit new_piece_path
          expect_create_piece_success i, i
        end
      end

      scenario "User sees all the pieces displayed" do
        visit pieces_path

        piece_rows = all("tr.piece-row")

        piece_rows.count.should == @pieces_count

        piece_rows.each_with_index do |piece, index|
          expected_index = @pieces_count - index - 1
          within piece do
            within ".piece-links" do
              should have_link "edit"
              should have_css ".delete-piece-link"
              should have_link "all versions"
            end

            find(".piece-title").text.should == expected_index.to_s
            find(".piece-blurb").text.should == expected_index.to_s
            find(".piece-last-modified").text.should match /Last modified .* ago/
          end
        end
      end
    end

    context "when user clicks on link to create first piece" do
      background { click_new_link }

      it_behaves_like "a user creating a piece"
    end

    context "when user has created a piece" do
      background do
        follow_link_and_create_piece
        @piece = Piece.first
        @title = @piece.current_version.title
        @content = @piece.current_version.content
      end

      scenario "sees they have no pieces after deleting the created piece" do
        gui_delete_piece
        should have_content "You have no pieces."
      end

      context "when on the pieces path" do
        background do
          visit pieces_path
        end

        scenario "User sees links for piece" do
          should_not have_content "You have no pieces."

          should have_link @title

          has_edit_link
          has_delete_link
        end

        scenario "User visits piece and sees content" do
          click_link @title

          should have_content @title
          should have_content @content
        end

        context "when user clicks on the edit link" do
          background { click_edit_link }
          
          it_behaves_like "a user editing a piece"
        end

        it_behaves_like "a user deleting a piece"
      end
      
      context "and is on a piece page" do
        background do
          @piece = Piece.first
          visit piece_path @piece
        end

        it_behaves_like "piece bar with history" do
          let(:piece) { @piece }
        end

        context "when user clicks on the edit link" do
          background { click_edit_link }
          
          it_behaves_like "a user editing a piece"
        end

        it_behaves_like "a user deleting a piece"
      end
    end
  end
end
