shared_context "common" do
  background do
    login_with_oauth
  end

  subject { page }
end

feature "Pieces Management", "User wants to create a new piece" do
  include_context "common"

  context "from a page with a piece bar" do
    background do
      visit pieces_path
      first("a.create-piece").click
    end

    it_behaves_like "a user creating a piece"
  end
end

feature "Pieces Management", "User wants to see text formatted as entered" do
  include_context "common"
  require 'faker'

  [1,3].each do |num|
    scenario "User sees #{num} lines rendered properly" do
      user = User.last
      piece = FactoryGirl.create :piece, user: user, versions_count: 0
      FactoryGirl.create :version,
        piece: piece,
        title: "",
        content: Faker::Lorem.sentences(num).join("\n\n")
      visit piece_path id: piece.id

      within '#content' do
        should have_css "p", count: num
      end
    end
  end
end

feature "Pieces Management", "User wants to see all their pieces" do
  include_context "common"

  context "with no pieces" do
    background { visit pieces_path }

    it_behaves_like "piece bar"

    scenario "User sees they have no pieces" do
      should have_content "your pieces"
      should have_content "You have no pieces."
    end
  end

  context "with at least one piece" do
    background do
      user = User.last

      @pieces = []
      5.times do |i|
        @pieces << FactoryGirl.create(:piece, user: user, versions_count: 1)
      end
      @pieces.reverse!

      visit pieces_path
    end

    #TODO: Should this be in a view spec?
    it_behaves_like "piece bar"

    scenario "User sees all the pieces displayed" do
      piece_rows = all "tr.piece-row"

      piece_rows.count.should == @pieces.count

      piece_rows.each.with_index do |piece, i|
        within piece do
          within ".piece-links" do
            should have_link "edit"
            should have_css ".delete-piece-link"
            should have_link "history"
          end

          find(".piece-title").text.should == @pieces[i].short_title
          find(".piece-blurb").text.should == @pieces[i].blurb
          find(".piece-last-modified").text.should match /Last modified .* ago/
        end
      end
    end
  end
end

shared_context "user piece" do
  include_context "common" 

  background do
    user = User.last
    @piece = FactoryGirl.create :piece, user: user, versions_count: 1
  end
end

feature "Pieces Management", "User wants to see a piece they've created" do
  include_context "user piece"

  background { visit pieces_path }
  
  scenario "User sees the links for the piece" do
    should have_link @piece.title
    has_edit_link
    has_delete_link
  end

  context "on the piece page" do
    background { click_link @piece.title }

    it_behaves_like "piece bar for history" do
      let(:piece) { @piece }
    end

    scenario "User can find and view the piece" do
      should have_content @piece.title
      should have_content @piece.content
    end
  end
end

feature "Pieces Management", "User wants to edit a piece they've created" do
  include_context "user piece"

  context "from the pieces page" do
    background do
      visit pieces_path
      first(:link, "edit").click
    end

    it_behaves_like "a user editing a piece"
  end

  context "from the piece page" do
    background do
      visit piece_path id: @piece.id
      first(:link, "edit").click
    end

    it_behaves_like "a user editing a piece"
  end
end

feature "Pieces Management", "User wants to delete a piece they've created" do
  include_context "user piece"

  context "from the pieces page" do
    background do
      visit pieces_path
    end

    it_behaves_like "a user deleting a piece"
  end

  context "from the piece page" do
    background do
      visit piece_path id: @piece.id
    end

    it_behaves_like "a user deleting a piece"
  end
end

shared_examples "User sees the drafts" do
  scenario "User sees the drafts" do
    history_rows = all(".history-row")
    history_rows.count.should be > 0
    history_rows.count.should == @versions.count

    should_not have_content "version"

    history_rows.each.with_index do |v, i|
      expected_index = history_rows.count - i - 1
      expected_version = @versions[expected_index]

      within v do
        should have_content expected_version.title
        should have_link expected_version.title, href: piece_draft_path(piece_id: expected_version.piece.id, id: expected_version.draft.number)
        should have_content "(draft ##{expected_version.draft.number})"
        should have_content /Last modified .* ago/
      end
    end
  end

end

feature "Pieces Management", "User wants to view the history of a piece" do
  context "with a user logged in" do
    context "who is the owner" do
      include_context "common"

      background do
        user = User.last
        @piece = create_piece user

        @versions = @piece.versions
        create_drafts @versions

        visit pieces_path
        first(:link, "history").click
      end

      it_behaves_like "piece bar for history" do
        let(:piece) { @piece }
      end

      scenario "User sees all versions and pieces" do
        history_rows = all(".history-row")
        history_rows.count.should be > 0
        history_rows.count.should eq @versions.count

        history_rows.each.with_index do |v, i|
          expected_index = history_rows.count - i - 1
          expected_version = @versions[expected_index]
          within v do
            should have_content expected_version.title

            if expected_version.draft.nil?
              should have_link expected_version.title, href: piece_version_path(piece_id: expected_version.piece.id, id: expected_version.number)
              should have_content "(version ##{expected_version.number})"
            else
              should have_link expected_version.title, href: piece_draft_path(piece_id: expected_version.piece.id, id: expected_version.draft.number)
              should have_content "(draft ##{expected_version.draft.number})"
            end

            should have_content /Last modified .* ago/
          end
        end
      end
    end

    context "who is not the owner" do
      include_context "common"

      background do
        user = create_user
        @piece = create_piece user
      end

      context "with no drafts" do
        background do
          visit history_piece_path id: @piece.id
        end

        it_behaves_like "no piece bar"

        scenario "User sees that there are no drafts" do
          should have_content "This piece has no history you can view."
        end
      end

      context "with at least one draft" do
        background do
          create_drafts @piece.versions
          @versions = @piece.versions.select{|v| !v.draft.nil? }

          visit history_piece_path id: @piece.id
        end

        it_behaves_like "no piece bar"

        include_examples "User sees the drafts"
      end
    end
  end

  context "with no user logged in" do
    subject { page }

    background do
      user = create_user
      @piece = create_piece user
    end

    context "with no drafts" do
      background do
        visit history_piece_path id: @piece.id
      end

      it_behaves_like "no piece bar"

      scenario "User sees that there are no drafts" do
        should have_content "This piece has no history you can view."
      end
    end

    context "with at least one draft" do
      background do
        create_drafts @piece.versions
        @versions = @piece.versions.select{|v| !v.draft.nil? }

        visit history_piece_path id: @piece.id
      end

      it_behaves_like "no piece bar"

      include_examples "User sees the drafts"
    end
  end
end
