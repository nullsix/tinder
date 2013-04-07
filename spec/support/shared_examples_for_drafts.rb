shared_examples "draft information" do
  scenario "shows draft information" do
    should have_content @piece.title
    should have_content @piece.content
    find(".created-time").text.should match /created .* ago/
  end
end

shared_examples "logged in draft information" do
  it_behaves_like "piece bar for draft" do
    let(:piece) { @piece }
    let(:draft) { @draft }
  end

  it_behaves_like "draft information"

  scenario "shows the right extra info" do
    should have_link "##{@draft.number}", href: piece_draft_path(piece_id: @piece, id: @draft.number)
    should_not have_content "by #{@piece.user.name}"
  end
end

shared_examples "non owner draft information" do
  it_behaves_like "draft information"

  scenario "shows the piece's user's name" do
    should have_content "by #{@piece.user.name}"
  end
end
