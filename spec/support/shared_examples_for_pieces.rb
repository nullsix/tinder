include PieceHelper

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
    gui_delete_piece
    should_not have_link title
    within "div.alert-success" do
      should have_content "Piece was successfully deleted."
    end
  end
end
