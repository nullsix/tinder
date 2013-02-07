feature "Pieces Management" do
  shared_examples "a user seeing a new piece form" do
    scenario "User sees the form" do
      should have_content "new piece"
      verify_user_sees_piece_form
    end
  end

  shared_examples "a user creating a piece" do
    it_behaves_like "a user seeing a new piece form"

    context "successfully" do 
      scenario "with blank title" do
        expect_create_piece_success("")
        verify_piece_was_created
      end

      scenario "with non-blank title" do
        expect_create_piece_success
        verify_piece_was_created
      end
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

    context "successfully" do
      scenario "with blank title" do
        content = "blah blah"
        expect_edit_piece_success "", content
        verify_piece_was_edited "Untitled Piece", content
      end

      scenario "with non-blank title" do
        title = "This is not blank"
        content = "Nor is this"
        expect_edit_piece_success title, content
        verify_piece_was_edited title, content
      end
    end

    scenario "doesn't update the piece" do
      expect_edit_piece_no_change

      verify_piece_wasnt_updated
    end

    scenario "unsuccessfully at first but corrects it" do
      expect_edit_piece_failure
      verify_piece_was_not_accepted
      title = "This is a modified title!"
      content = "This is a modified content too!"
      expect_edit_piece_success title, content
      verify_piece_was_edited title, content
    end
  end

  shared_examples "a user deleting a piece" do
    scenario "successfully" do
      @piece = Piece.last
      title = @piece.current_version.title
      user_deletes_piece
      should_not have_link title
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
              should have_css ".delete"
            end

            find(".piece-title").text.should == expected_index.to_s
            find(".piece-blurb").text.should == expected_index.to_s
            find(".piece-last-modified").text.should match /Last modified .* ago/
          end
        end
      end
    end

    scenario "User sees they have no pieces" do
      should have_content "your pieces"
      should have_content "You have no pieces."
      should have_link "Create one!", href: new_piece_path
    end

    context "when user clicks on link to create first piece" do
      background { click_link "Create one!" }

      it_behaves_like "a user creating a piece"
    end

    context "when user has created a piece" do
      background do
        follow_link_and_create_piece
        @piece = Piece.last
        @title = @piece.current_version.title
        @content = @piece.current_version.content
      end

      scenario "sees they have no pieces after deleting the created piece" do
        user_deletes_piece
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
          @piece = Piece.last
          visit piece_path @piece
        end

        scenario "User sees edit/delete links" do
          should have_css "p.links", count: 2
          has_edit_link
          has_delete_link
        end

        context "when user clicks on the edit link" do
          background { click_edit_link }
          
          it_behaves_like "a user editing a piece"
        end

        it_behaves_like "a user deleting a piece"
      end
    end
  end

  private 
    # General form actions
    def has_edit_link
      should have_link "edit"
      should have_css 'a button i.icon-edit'
    end

    def has_delete_link
      should have_css 'a button i.icon-trash'
    end

    def click_edit_link
      all("a").select { |e| e.text == "edit" }.first.click
    end
    
    def click_delete_link
      all("a.delete").first.click
    end

    def verify_user_sees_piece_form
      should have_selector "#version_title"
      should have_selector "#version_content"
    end

    def fill_in_piece_form(title, content)
      fill_in :version_title, with: title
      fill_in :version_content, with: content
    end

    def title_or_default(title)
      "Untitled Piece" if title.nil? || title.empty?
      title
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

      title = title_or_default @title

      within "h2" do
        should have_content title
      end

      visit pieces_path
      should have_link title
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

    def expect_edit_piece_no_change
      expect {
        expect {
          fill_in :version_title, with: @piece.current_version.title
          fill_in :version_content, with: @piece.current_version.content

          click_button "Update Piece"
        }.not_to change(Version, :count)
      }.not_to change(Piece, :count)
    end

    def expect_edit_piece_failure(title = "a"*300)
      expect {
        expect {
          edit_piece title, "This is a good content modification."
        }.not_to change(Version, :count)
      }.not_to change(Piece, :count)
    end

    def verify_piece_was_edited (title, content)
      within "div.alert-success" do
        should have_content "Piece was successfully updated."
      end

      title = title_or_default title
      within "h2" do
        should have_content title
      end

      should have_content content
    end

    def verify_piece_wasnt_updated
      within "div.alert-success" do
        should have_content "Piece was already saved."
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
          click_delete_link
        }.to change(Piece, :count).by -1
      }.to change(Version, :count).by @piece.versions.count*-1
    end
end
