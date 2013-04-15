feature "Versions Management" do
  before :each do
    login_with_oauth

    @piece = FactoryGirl.create :piece, user_id: User.last.id, versions_count: 0

    @versions = []
    5.times do |i|
      @versions << FactoryGirl.create(:version, piece_id: @piece.id, title: i.to_s, content: i.to_s, number: (i+1).to_s)
    end
  end

  subject { page }

  context "view a piece's versions" do
    scenario "redirects to history" do
      version = @versions.last
      visit piece_versions_path @piece.id

      current_path.should == history_piece_path(id: @piece.id)
    end
  end

  context "view a piece's version" do
    before :each do
      @version_wanted = @versions.last
      visit piece_version_path @piece.id, @version_wanted.number
    end

    it_behaves_like "piece bar for history" do
      let(:piece) { @piece }
    end

    scenario "displays a version's data" do
      within ".version" do
        should have_content @version_wanted.title
        should have_content @version_wanted.content
      end
    end
  end
end
