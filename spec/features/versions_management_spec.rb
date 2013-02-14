feature "Versions Management" do
  before :each do
    login_with_oauth

    @piece = FactoryGirl.create :piece, user_id: User.last.id, versions_count: 0

    @versions = []
    5.times do |i|
      @versions << FactoryGirl.create(:version, piece_id: @piece.id, title: i.to_s, content: i.to_s)
    end
  end

  context "view a piece's versions" do
    before :each do
      visit piece_versions_path @piece.id
    end

    subject { page }

    scenario "displays the piece's versions" do
      should have_content "#{@piece.title} - versions"
      should have_link @piece.title

      within ".versions" do
        version_rows = all("tr.version-row")
        version_rows.count.should == @versions.count

        version_rows.each_with_index do |version, index|
          expected_index = @versions.count - index - 1
          within version do
            find(".version-title").should have_content @versions[expected_index].title
            find(".version-title").should have_link @versions[expected_index].title, href: piece_version_path(piece_id: @piece.id, id: @versions[expected_index].id)
            find(".version-number").should have_content /(version ##{expected_index+1})/
            find(".version-last-modified").should have_content /Last modified .* ago/
          end
        end
      end
    end

    scenario "displays a version's data" do
      version_wanted = @versions.last
      within ".versions" do
        all("a").select { |e| e.text == version_wanted.title }.first.click
      end

      within ".version" do
        within ".piece-title" do
          should have_content /a version of '#{@piece.title}'/
          should have_link @piece.title
        end

        should have_link "see all versions"
        should have_content version_wanted.title
        should have_content version_wanted.content
      end
    end
  end
end
