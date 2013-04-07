module PieceHelper
  #Non-GUI actions
  #
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

  #GUI actions
  #

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

  def gui_create_piece(title, content)
    fill_in_piece_form title, content

    click_button "Create Piece"
  end

  def expect_create_piece_success(title = "Testing title!", content = "Testing content!")
    expect {
      expect {
        gui_create_piece title, content
      }.to change(Version, :count).by 1
    }.to change(Piece, :count).by 1
  end

  def expect_create_piece_failure(title = "a"*300)
    expect {
      expect {
        gui_create_piece title, "This should be good content!\n\nIt has multiple lines."
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
  def gui_edit_piece(title, content)
    fill_in_piece_form title, content

    click_button "Update Piece"
  end

  def expect_edit_piece_success(title = "Modified testing title!", content = "Modified testing content!")
    expect {
      expect {
        gui_edit_piece title, content
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
        gui_edit_piece title, "This is a good content modification."
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

  # Delete testing
  def gui_delete_piece
    expect {
      expect {
        click_delete_link
      }.to change(Piece, :count).by -1
    }.to change(Version, :count).by @piece.versions.count*-1
  end

  # Draft testing
  def gui_create_draft
    visit piece_path @piece
    all("a.make-draft-link").first.click
    @draft = @piece.current_version.draft
  end
end
