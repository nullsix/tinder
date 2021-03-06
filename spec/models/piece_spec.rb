# == Schema Information
#
# Table name: pieces
#
#  id         :integer          not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :integer
#

require 'spec_helper'

describe Piece do
  it "has a valid factory" do
    FactoryGirl.build_stubbed(:piece).should be_valid
  end

  let(:piece) { FactoryGirl.create :piece }

  subject { piece }

  describe "#user" do
    subject { piece.user }

    it_behaves_like "instance method" do
      let(:instance) { piece }
      let(:method) { :user }
    end

    it "is" do
      should be
    end
  end

  describe "#versions" do
    it_behaves_like "instance method" do
      let(:instance) { piece }
      let(:method) { :versions }
    end

    subject { piece.versions }

    context "before piece is saved" do
      let(:piece) { FactoryGirl.build :piece }

      it "has no versions" do
        should be_empty
      end
    end

    context "after piece is saved" do
      let(:versions_count) { 5 }
      let(:piece) { FactoryGirl.create :piece, versions_count: versions_count }

      it "is not empty" do
        should_not be_empty
      end

      it "returns the correct number of versions" do
        subject.count.should == versions_count
      end

      it "is in the right order" do
        expected_order = piece.versions.sort_by(&:created_at)
        should == expected_order
      end
    end
  end

  describe "#drafts" do
    it_behaves_like "instance method" do
      let(:instance) { piece }
      let(:method) { :drafts }
    end

    subject { piece.drafts }

    context "before piece is saved" do
      let(:piece) { FactoryGirl.build :piece }

      it "has no drafts" do
        should be_empty
      end
    end

    context "after piece is saved" do
      let(:versions_count) { 5 }
      let(:piece) { FactoryGirl.create :piece, versions_count: versions_count }

      context "with no drafts" do
        it "has no drafts" do
          should be_empty
        end
      end

      context "with drafts" do
        let!(:drafts) do
            d = []
            piece.versions.each do |v|
              d << create_draft(v)
            end
            d
        end

        it "is not empty" do
          should_not be_empty
        end

        it "has all the drafts" do
          should == drafts
        end
      end
    end
  end

  describe "#current_version" do
    it_behaves_like "instance method" do
      let(:instance) { piece }
      let(:method) { :current_version }
    end

    subject { piece.current_version }

    context "with multiple versions" do
      it "is the last item in #versions" do
        should == piece.versions.last
      end

      context "after current_version is deleted" do
        let(:versions_count) { 2 }
        let(:piece) { FactoryGirl.create :piece, versions_count: versions_count }

        it "current_version is set to the next to last version" do
          expected_current_version = piece.versions[versions_count-1]
          subject.delete
          should == expected_current_version
        end
      end
    end

    context "with no versions" do
      subject { FactoryGirl.build :piece, versions_count: 0 }

      it "is nil" do
        subject.current_version.should be_nil
      end
    end
  end

  describe "#title" do
    let(:piece) do
      FactoryGirl.create :piece, title: rand.to_s, content: rand.to_s
    end

    subject { piece.title }

    it_behaves_like "instance method" do
      let(:instance) { piece }
      let(:method) { :title }
    end

    context "before piece is saved" do
      let(:piece) { FactoryGirl.build :piece, versions_count: 0 }

      it "is default" do
        should == "Untitled Piece"
      end
    end

    context "after piece is saved" do
      context "with a current_version" do
        context "and retrieved from DB again" do
          it "has the current_version's title" do
            title = piece.current_version.title
            piece = Piece.last
            piece.title.should == title
          end
        end

        it "is the current_version's title" do
          should == piece.current_version.title
        end
      end

      context "with no current_version" do
        let(:piece) { FactoryGirl.create :piece }

        it "is default" do
          piece.versions.delete_all
          should == "Untitled Piece"
        end
      end
    end
  end

  describe "#title=" do
    subject { piece.title }

    it_behaves_like "instance method" do
      let(:instance) { piece }
      let(:method) { :title= }
    end

    shared_examples "sets title" do
      it "uses default when nil" do
        piece.title = nil
        subject.should == "Untitled Piece"
      end

      it "uses default when empty" do
        piece.title = ""
        subject.should == "Untitled Piece"
      end

      it "changes title" do
        title = rand.to_s
        piece.title = title
        should == title
      end

      # Or should this be in the short_title tests?
      it "changes short_title" do
        title = "a"*100
        piece.title = title
        piece.short_title.should == "a"*27+"..."
      end
    end

    context "before piece is saved" do
      let(:piece) { FactoryGirl.build :piece, versions_count: 0 }

      it_behaves_like "sets title"
    end

    context "after piece is saved" do
      let(:piece) { FactoryGirl.create :piece }

      it_behaves_like "sets title"
    end
  end

  shared_examples "sets short_title" do
    context "when title is changed" do
      context "with a title more than 30 characters" do
        it "is shortened" do
          piece.title = "a"*50
          should == "a"*27+"..."
        end
      end

      context "with a title no more than 30 characters" do
        it "is the title" do
          piece.title = "a"*30
          should == piece.title
        end
      end
    end
  end

  describe "#short_title" do
    subject { piece.short_title }

    it_behaves_like "instance method" do
      let(:instance) { piece }
      let(:method) { :short_title }
    end

    context "before piece is saved" do
      let(:piece) { FactoryGirl.build :piece, versions_count: 0 }

      it "is default" do
        should == piece.title
      end

      it_behaves_like "sets short_title"
    end

    context "after piece is saved" do
      context "with a current_version" do
        it "is the current_version's short_title at first" do
          should == piece.current_version.short_title
        end

        it_behaves_like "sets short_title"
      end

      context "with no current_version" do
        let!(:piece) do
          p = FactoryGirl.create :piece
          p.versions.delete_all
          p
        end

        it "is default" do
          should == piece.title
        end

        it_behaves_like "sets short_title"
      end
    end
  end

  describe "#content" do
    subject { piece.content }

    it_behaves_like "instance method" do
      let(:instance) { piece }
      let(:method) { :content }
    end

    context "before piece is saved" do
      let(:piece) { FactoryGirl.build :piece, versions_count: 0 }

      it "is default" do
        should be_empty
      end
    end

    context "after piece is saved" do
      context "with a current version" do
        it "is the current_version's content" do
          should == piece.current_version.content
        end
      end

      context "with no current_version" do
        let(:piece) { FactoryGirl.create :piece }

        it "is default" do
          piece.versions.delete_all
          should be_empty
        end
      end
    end
  end

  describe "#content=" do
    subject { piece.content }

    it_behaves_like "instance method" do
      let(:instance) { piece }
      let(:method) { :content= }
    end

    shared_examples "sets content" do
      it "changes content" do
        content = rand.to_s
        piece.content = content
        should == content
      end

      it "defaults to empty string when nil" do
        piece.content = nil
        should == ""
      end

      it "changes blurb" do
        content = "a"*100
        piece.content = content
        piece.blurb.should == "a"*47+"..."
      end
    end

    context "before piece is saved" do
      let(:piece) { FactoryGirl.build :piece, versions_count: 0 }

      it_behaves_like "sets content"
    end

    context "after piece is saved" do
      let(:piece) { FactoryGirl.create :piece }

      it_behaves_like "sets content"
    end
  end

  shared_examples "sets blurb" do
    context "when content is changed" do
      context "with a title more than 50 characters" do
        it "is shortened" do
          piece.content = "a"*100
          should == "a"*47+"..."
        end
      end

      context "with a content no more than 50 characters" do
        it "is the content" do
          piece.content = "a"*50
          should == piece.content
        end
      end
    end
  end

  describe "#blurb" do
    subject { piece.blurb }

    it_behaves_like "instance method" do
      let(:instance) { piece }
      let(:method) { :blurb }
    end

    context "before piece is saved" do
      let(:piece) { FactoryGirl.build :piece, versions_count: 0 }

      it "is default" do
        should be_empty
      end

      it_behaves_like "sets blurb"
    end

    context "after piece is saved" do
      context "with a current_version" do
        it "is the current_version's blurb at first" do
          should == piece.current_version.blurb
        end

        it_behaves_like "sets blurb"
      end

      context "with no current_version" do
        let!(:piece) do
          p = FactoryGirl.create :piece
          p.versions.delete_all
          p
        end

        it "is default" do
          should be_empty
        end

        it_behaves_like "sets blurb"
      end
    end
  end

  describe "#changed?" do
    subject { piece.changed? }
    
    it_behaves_like "instance method" do
      let(:instance) { piece }
      let(:method) { :changed? }
    end

    context "with no changes" do
      it "is false" do
        should be_false
      end
    end

    context "with title changed" do
      it "is true" do
        piece.title = rand.to_s
        should be_true
      end
    end

    context "with content changed" do
      it "is true" do
        piece.content = rand.to_s
        should be_true
      end
    end

    context "with title and content changed" do
      it "is true" do
        piece.title = rand.to_s
        piece.content = rand.to_s
        should be_true
      end
    end
  end

  describe "#create_draft" do
    let(:versions_count) { 5 }
    let(:piece) { FactoryGirl.create :piece, versions_count: versions_count }

    it "creates a draft" do
      piece.create_draft
      piece.drafts.should_not be_empty
    end

    specify "draft.number is correct" do
      # the number is not based on the collection size
      piece.versions[1..versions_count-1].each do |v|
        piece.create_draft v
      end
    
      piece.create_draft
      piece.drafts.last.number.should == versions_count
    end

    it "defaults to current_version" do
      piece.create_draft
      piece.drafts.first.version.should == piece.current_version
    end

    it "doesn't create a duplicate draft" do
      piece.create_draft
      piece.create_draft
      piece.drafts.count.should_not > 1
    end

    it "allows you to specify a version" do
      version = piece.versions.first
      piece.create_draft version
      piece.drafts.first.version.should == version
    end
  end

  describe "versioning" do
    context "with a new piece" do
      let(:piece) { FactoryGirl.build :piece, versions_count: 0 }
      subject { piece }

      specify "title is default" do
        subject.title.should == "Untitled Piece"
      end

      it "content is empty" do
        subject.content.should be_empty
      end

      it "can be assigned a new title" do
        s = rand.to_s
        piece.title = s
        subject.title.should == s
      end

      it "can be assigned a new content" do
        s = rand.to_s
        piece.content = s
        subject.content.should == s
      end

      it "has no current_version" do
        subject.current_version.should be_nil
      end

      context "when saved" do
        let(:title) { rand.to_s }

        let(:content) { rand.to_s }

        let(:piece) do
          FactoryGirl.build :piece, versions_count: 0, title: title, content: content
        end

        it "creates a version" do
          expect { piece.save }.to change(piece.versions, :count).by 1
        end

        specify "current_version is set" do
          piece.save
          piece.current_version.should be
        end

        specify "title is correct" do
          piece.save
          subject.title.should == title
        end

        specify "content is correct" do
          piece.save
          subject.content.should == content
        end
      end
    end

    shared_examples "modifying the piece" do
      it "creates a new version" do
        expect { piece.save }.to change(piece.versions, :count).by 1
      end

      specify "new version's number is correct" do
        expected_number = piece.versions.last.number + 1
        piece.save
        subject.current_version.number.should == expected_number
      end

      specify "new version is the piece's current version" do
        piece.save
        subject.current_version.should == Version.last
      end
    end

    context "with a saved piece" do
      let(:piece) do
        FactoryGirl.create :piece, title: rand.to_s, content: rand.to_s
      end

      subject { piece }

      shared_examples "piece updated_at changed" do
        it "changes #updated_at" do
          original_time = piece.updated_at
          piece.save
          piece.updated_at.should_not == original_time
        end
      end

      context "with the first version deleted" do
        specify "new version has the right number" do
          piece.save
          piece.title = rand.to_s
          piece.save
          piece.versions.first.delete
          piece.title = rand.to_s
          piece.save
          expected_number = 3

          piece.current_version.number.should == expected_number
        end
      end

      context "when title changes" do
        before :each do
          @new_title = rand.to_s
          @content = piece.content
          subject.title = @new_title
        end

        include_examples "modifying the piece"

        include_examples "piece updated_at changed"

        context "after the save" do
          before :each do
            piece.save
          end

          it "has the new title" do
            subject.title.should == @new_title
          end

          it "has the old content" do
            subject.content.should == @content
          end

          specify "#current_version has the new title" do
            subject.current_version.title.should == @new_title
          end

          specify "#current_version had the old content" do
            subject.current_version.content.should == @content
          end

          specify "new version's title is the new title" do
            version = Version.last
            version.title.should == @new_title
          end

          specify "new version's content is the old content" do
            version = Version.last
            version.content.should == @content
          end

          specify "#blurb is the current_version's blurb" do
            subject.blurb.should == subject.current_version.blurb
          end

          specify "#short_title is the current_version's short_title" do
            subject.short_title.should == subject.current_version.short_title
          end
        end
      end

      context "when content changes" do
        before :each do
          @new_content = rand.to_s
          @title = piece.title
          piece.content = @new_content
        end

        include_examples "modifying the piece"

        include_examples "piece updated_at changed"

        context "after the save" do
          before :each do
            piece.save
          end

          it "has the new content" do
            piece.content.should == @new_content
          end

          it "has the old title" do
            piece.title.should == @title
          end

          specify "#current_version has the new content" do
            subject.current_version.content.should == @new_content
          end

          specify "#current_version had the old title" do
            subject.current_version.title.should == @title
          end

          specify "new version's content is the new content" do
            version = Version.last
            version.content.should == @new_content
          end

          specify "new version's title is the old title" do
            version = Version.last
            version.title.should == @title
          end

          specify "#blurb is the current_version's blurb" do
            subject.blurb.should == subject.current_version.blurb
          end

          specify "#short_title is the current_version's short_title" do
            subject.short_title.should == subject.current_version.short_title
          end
        end
      end

      context "when the title and content change" do
        # ditto as above
        before :each do
          @new_title = rand.to_s
          @new_content = rand.to_s

          @title = piece.title
          @content = piece.content

          piece.title = @new_title
          piece.content = @new_content
        end

        include_examples "modifying the piece"

        include_examples "piece updated_at changed"

        context "after the save" do
          before :each do
            piece.save
          end

          it "has the new title" do
            piece.title.should == @new_title
          end

          it "has the new content" do
            piece.content.should == @new_content
          end

          specify "#current_version has the new title" do
            subject.current_version.title.should == @new_title
          end

          specify "#current_version had the new content" do
            subject.current_version.content.should == @new_content
          end

          specify "new version's title is the new title" do
            version = Version.last
            version.title.should == @new_title
          end

          specify "new version's content is the old content" do
            version = Version.last
            version.content.should == @new_content
          end

          specify "#blurb is the current_version's blurb" do
            subject.blurb.should == subject.current_version.blurb
          end

          specify "#short_title is the current_version's short_title" do
            subject.short_title.should == subject.current_version.short_title
          end
        end
      end
    end
  end

  describe "validations" do
    it "is valid with a user" do
      user = FactoryGirl.build_stubbed :user
      piece = FactoryGirl.build_stubbed :piece, user: user
      piece.should be_valid
    end

    it "is invalid without a user" do
      piece = FactoryGirl.build_stubbed :piece, user: nil
      piece.should_not be_valid
    end

    it "is invalid with a title longer than 255 characters" do
      piece = FactoryGirl.build_stubbed :piece, title: "a"*300
      piece.should_not be_valid
    end

    it "is valid with a title less than or equal to 255 characters" do
      piece = FactoryGirl.build_stubbed :piece, title: "a"*255
      piece.should be_valid
    end
  end

  describe "scopes" do
    shared_context "with pieces" do
      let(:pieces) do
        pieces = []
        5.times do
          pieces << FactoryGirl.create(:piece)
        end
        pieces.reverse!
      end
    end

    context "default" do
      include_context "with pieces"
      it "returns last modified pieces" do
        pieces
        Piece.all.should == pieces
      end
    end

    context "last_modified_first" do
      include_context "with pieces"
      it "returns last modified pieces" do
        pieces
        Piece.last_modified_first.should == pieces
      end
    end
  end
end
