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
            find(".version-number").should have_content /(version ##{expected_index+1})/
            find(".version-last-modified").should have_content /Last modified .* ago/
          end
        end
      end
    end
  end
end
