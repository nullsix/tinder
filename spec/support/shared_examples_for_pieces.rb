module PieceHelper
  # General form actions
  def has_edit_link
    should have_link "edit"
    should have_css 'a button i.icon-edit'
  end

  def has_delete_link
    should have_css 'a button i.icon-trash'
  end

  def click_new_link
    all("a.create-piece").first.click
  end

  def click_edit_link
    all("a.edit-piece-link").first.click
  end
  
  def click_delete_link
    all("a.delete-piece-link").first.click
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
    click_new_link

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
