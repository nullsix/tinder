shared_examples "draft information" do
  scenario "shows draft information" do
    should have_content @piece.title
    should have_content @piece.content
    find(".created-time").text.should match /created .* ago/
  end
end

shared_examples "logged in draft information" do
  it_behaves_like "piece bar for history" do
    let(:piece) { @piece }
  end

  it_behaves_like "draft information"

  scenario "shows no extra info" do
    should_not have_content "by #{@piece.user.name}"
  end
end

shared_examples "non owner draft information" do
  it_behaves_like "draft information"

  scenario "shows the piece's user's name" do
    should have_link "history", href: history_piece_path(id: @piece.id)
    should have_content "by #{@piece.user.name}"
  end
end
