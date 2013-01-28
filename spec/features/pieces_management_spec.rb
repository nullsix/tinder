feature "Pieces Management" do
  background do
    login_with_oauth
    visit pieces_path
  end

  subject { page }

  scenario "User visits pieces path and has no pieces" do
    should have_content "your pieces"
    should have_content "You have no pieces."
    should have_link "Create one!", href: new_piece_path
  end

  scenario "User creates first piece" do
    user_creates_piece

    within "div.alert-success" do
      should have_content "Piece was successfully created."
    end

    within "h2" do
      should have_content @title
    end

    should have_content @content
  end

  scenario "User visits pieces path after creating a piece" do
    user_creates_piece

    visit pieces_path
    should_not have_content "You have no pieces."

    should have_link @title
    should have_link "edit"
    should have_link "delete"
  end

  context "from the pieces page" do
    background do
      user_creates_piece
      visit pieces_path
    end

    scenario "User views an existing piece" do
      click_link @title

      should have_content @title
      should have_content @content
    end

    scenario "User edits an existing piece" do
      user_edits_piece
      
      should have_content @new_title
      should have_content @new_content
    end

    scenario "User deletes an existing piece" do
      @piece = Piece.last
      user_deletes_piece

      should_not have_link @title
      should have_content "You have no pieces."
    end
  end

  context "from the piece page" do
    background do
      user_creates_piece
      @piece = Piece.last
      visit piece_path @piece
    end
    
    scenario "User edits the piece" do
      user_edits_piece
      
      should have_content @new_title
      should have_content @new_content
    end

    scenario "User deletes the piece" do
      @piece = Piece.last
      user_deletes_piece

      should_not have_link @title
      should have_content "You have no pieces."
    end
  end

  private 
    def user_creates_piece
     expect {
       expect {
         click_link "Create one!"

         @title = "Testing title!"
         @content = "Testing content!"

         fill_in :version_title, with: @title
         fill_in :version_content, with: @content
         click_button "Create Piece"
       }.to change(Piece, :count).by 1
     }.to change(Version, :count).by 1
    end

    def user_edits_piece
      expect {
        expect {
          click_link "edit"

          @new_title = "New testing title!"
          @new_content = "New testing content!"

          fill_in :version_title, with: @new_title
          fill_in :version_content, with: @new_content
          click_button "Update Piece"
        }.to change(Version, :count).by 1
      }.not_to change(Piece, :count)
    end

    def user_deletes_piece
      expect {
        expect {
          click_link "delete"
        }.to change(Piece, :count).by -1
      }.to change(Version, :count).by @piece.versions.count*-1
    end
end
