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

shared_examples "instance method" do
  subject { piece }

  it "exists" do
    should respond_to method
  end
end

describe Piece do
  it "has a valid factory" do
    FactoryGirl.build_stubbed(:piece).should be_valid
  end

  let(:piece) { FactoryGirl.create :piece }

  subject { piece }

  describe "#user" do
    subject { piece.user }

    it_behaves_like "instance method" do
      let(:method) { :user }
    end

    it "is" do
      should be
    end
  end

  describe "#versions" do
    it_behaves_like "instance method" do
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
      let(:method) { :current_version }
    end

    subject { piece.current_version }

    context "with multiple versions" do
      it "is the last item in #versions" do
        should == piece.versions.last
      end

      context "after current_version is deleted" do
        let(:piece) { FactoryGirl.create :piece, versions_count: 2 }

        it "current_version is set to the next to last version" do
          expected_current_version = piece.versions[0]
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
    subject { piece.title }

    it_behaves_like "instance method" do
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
      let(:method) { :title= }
    end

    it "gets a default when empty" do
      piece.title = ""
      should == "Untitled Piece"
    end

    it "changes the short_title" do
      title = "a"*100
      piece.title = title
      piece.short_title.should == "a"*27+"..."
    end
  end

  describe "#content" do
    subject { piece.content }

    it_behaves_like "instance method" do
      let(:method) { :content }
    end

    context "with a version" do
      it "is the current version's content" do
        should == piece.current_version.content
      end
    end

    context "with no versions" do
      it "is nil" do
        piece.versions.destroy_all

        should be_nil
      end
    end
  end

  describe "#content=" do
    it_behaves_like "instance method" do
      let(:method) { :content= }
    end

    it "changes the blurb" do
      content = "a"*100
      piece.content = content
      piece.blurb.should == "a"*47+"..."
    end
  end

  describe "#short_title" do
    subject { piece.short_title }

    it_behaves_like "instance method" do
      let(:method) { :short_title }
    end

    context "with a version" do
      it "is the current version's short_title" do
        should == piece.current_version.short_title
      end
    end

    context "with no versions" do
      it "is nil" do
        piece.versions.destroy_all

        should be_nil
      end
    end
  end

  describe "#blurb" do
    subject { piece.blurb }

    it_behaves_like "instance method" do
      let(:method) { :blurb }
    end

    context "with a version" do
      it "is the current version's blurb" do
        should == piece.current_version.blurb
      end
    end

    context "with no versions" do
      it "is nil" do
        piece.versions.destroy_all

        should be_nil
      end
    end
  end



    end
  end

  describe "#changed?" do
    subject { piece.changed? }
    
    it_behaves_like "instance method" do
      let(:method) { :changed? }
    end

    context "with no changes" do
      it "is false" do
        should be_false
      end
    end

    context "with title changed" do
      it "is true" do
        piece.title = Time.now.to_s
        should be_true
      end
    end

    context "with content changed" do
      it "is true" do
        piece.content = Time.now.to_s
        should be_true
      end
    end

    context "with title and content changed" do
      it "is true" do
        piece.title = Time.now.to_s
        piece.content = Time.now.to_s
        should be_true
      end
    end
  end

  describe "immutable versions" do
    shared_examples "modifying the piece" do
      it "creates a new version" do
        expect { piece.save }.to change(piece.versions, :count).by 1
      end

      specify "new version's number is correct" do
        expected_number = piece.versions.count + 1
        piece.save
        piece.current_version.number.should == expected_number
      end

      specify "new version is the piece's current version" do
        piece.save
        piece.current_version.should == Version.last
      end
    end

    context "when title changes" do
      before :each do
        @new_title = Time.now.to_s
        @content = piece.content
        piece.title = @new_title
      end

      include_examples "modifying the piece"

      context "after the save" do
        before :each do
          piece.save
        end

        it "has the new title" do
          piece.title.should == @new_title
        end

        it "has the old content" do
          piece.content.should == @content
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
        @new_content = Time.now.to_s
        @title = piece.title
        piece.content = @new_content
      end

      include_examples "modifying the piece"

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
        @new_title = Time.now.to_s
        @new_content = Time.now.to_s

        @title = piece.title
        @content = piece.content

        piece.title = @new_title
        piece.content = @new_content
      end

      include_examples "modifying the piece"

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

  describe "validations" do
    it "must have a user" do
      no_user_piece = FactoryGirl.build_stubbed :piece, user: nil
      no_user_piece.should_not be_valid
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
