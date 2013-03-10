shared_examples "piece bar" do
  scenario "has two piece bars" do
    should have_css ".piece-bar", count: 2

    within(first(".piece-bar")) do
      should have_link "", href: new_piece_path
      should have_link "your pieces", href: pieces_path
    end
  end
end

shared_examples "piece bar for piece" do
  it_behaves_like "piece bar"

  scenario "shows piece links" do
    should have_link "edit", href: edit_piece_path(piece.id)
    should have_link piece.short_title, href: piece_path(piece.id)
    should have_link "", href: piece_path(piece.id)
    should have_css ".delete-piece-link"
  end
end

shared_examples "piece bar for versions" do
  it_behaves_like "piece bar for piece"

  scenario "shows all versions link" do
    should have_link "all versions", href: piece_versions_path(piece.id)
  end
end

shared_examples "piece bar for version" do
  it_behaves_like "piece bar for versions"

  scenario "shows version link" do
    should have_link version.short_title, href: piece_version_path(piece.id, version.id)
  end
end
