feature "Pieces Management" do
  shared_examples "a user seeing a new piece form" do
    scenario "User sees the form" do
      should have_content "new piece"
      verify_user_sees_piece_form
    end
  end

  shared_examples "a user creating a piece" do
    it_behaves_like "a user seeing a new piece form"

    scenario "successfully" do 
      expect_create_piece_success
      verify_piece_was_created
    end

    scenario "unsuccessfully at first but corrects it" do
      expect_create_piece_failure
      verify_piece_was_not_accepted
      expect_create_piece_success
      verify_piece_was_created
    end
  end

  shared_examples "a user editing a piece" do
    scenario "sees the form" do
      should have_content "edit piece"
      verify_user_sees_piece_form
    end

    scenario "successfully" do
      expect_edit_piece_success
      verify_piece_was_edited
    end

    scenario "unsuccessfully at first but corrects it" do
      expect_edit_piece_failure
      verify_piece_was_not_accepted
      expect_edit_piece_success
      verify_piece_was_edited
    end
  end

  shared_examples "a user deleting a piece" do
    scenario "successfully" do
      @piece = Piece.last
      user_deletes_piece
      should_not have_link @title
      within "div.alert-success" do
        should have_content "Piece was successfully deleted."
      end
    end
  end

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

    scenario "User sees they have no pieces" do
      should have_content "your pieces"
      should have_content "You have no pieces."
      should have_link "Create one!", href: new_piece_path
    end

    context "User clicks on link to create first piece" do
      background { click_link "Create one!" }

      it_behaves_like "a user creating a piece"
    end

    context "User has created a piece" do
      background do
        follow_link_and_create_piece
      end

      scenario "sees they have no pieces after deleting the created piece" do
        @piece = Piece.last
        user_deletes_piece
        should have_content "You have no pieces."
      end

      context "and is on the pieces path" do
        background do
          visit pieces_path
        end

        scenario "User sees link for piece on the pieces path" do
          should_not have_content "You have no pieces."

          should have_link @title
          should have_link "edit"
          should have_link "delete"
        end

        scenario "User visits piece and sees content" do
          click_link @title

          should have_content @title
          should have_content @content
        end

        context "User clicks on the edit link" do
          background { click_link "edit" }
          
          it_behaves_like "a user editing a piece"
        end

        it_behaves_like "a user deleting a piece"
      end
      
      context "and is on a piece page" do
        background do
          @piece = Piece.last
          visit piece_path @piece
        end

        context "User clicks on the edit link" do
          background { click_link "edit" }
          
          it_behaves_like "a user editing a piece"
        end

        it_behaves_like "a user deleting a piece"
      end
    end
  end

  private 
    # General form actions
    def verify_user_sees_piece_form
      should have_selector "#version_title"
      should have_selector "#version_content"
    end

    def fill_in_piece_form(title, content)
      @title = title
      @content = content

      fill_in :version_title, with: @title
      fill_in :version_content, with: @content
    end

    def user_wants_to_fail?(hash = {})
      !hash.empty? && hash[:fail].exists?
    end

    # Create testing
    def follow_link_and_create_piece(hash = {})
      click_link "Create one!"

      if user_wants_to_fail? hash
        expect_create_piece_failure
      else
        expect_create_piece_success
      end
    end

    def create_piece(title, content)
      fill_in_piece_form title, content

      click_button "Create Piece"
    end

    def expect_create_piece_success(title = "Testing title!", content = "Testing content!")
      expect {
        expect {
          create_piece title, content
        }.to change(Version, :count).by 1
      }.to change(Piece, :count).by 1
    end

    def expect_create_piece_failure(title = "a"*300)
      expect {
        expect {
          create_piece title, "This should be good content!\n\nIt has multiple lines."
        }.not_to change(Version, :count).by 1
      }.not_to change(Piece, :count).by 1
    end

    def verify_piece_was_created
      within "div.alert-success" do
        should have_content "Piece was successfully created."
      end
      within "h2" do
        should have_content @title
      end

      visit pieces_path
      should have_link @title
    end

    # Edit testing
    def edit_piece(title, content)
      fill_in_piece_form title, content

      click_button "Update Piece"
    end

    def expect_edit_piece_success(title = "Modified testing title!", content = "Modified testing content!")
      expect {
        expect {
          edit_piece title, content
        }.to change(Version, :count).by 1
      }.not_to change(Piece, :count)
    end

    def expect_edit_piece_failure(title = "a"*300)
      expect {
        expect {
          edit_piece title, "This is a good piece modification."
        }.not_to change(Version, :count)
      }.not_to change(Piece, :count)
    end

    def verify_piece_was_edited
      within "div.alert-success" do
        should have_content "Piece was successfully updated."
      end

      within "h2" do
        should have_content @title
      end

      should have_content @content
    end

    def verify_piece_was_not_accepted
      should have_css "#error_explanation"
      should have_content "Title is too long"
    end

    def user_deletes_piece
      expect {
        expect {
          click_link "delete"
        }.to change(Piece, :count).by -1
      }.to change(Version, :count).by @piece.versions.count*-1
    end
end
