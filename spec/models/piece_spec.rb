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

  describe "#versions" do
    it_behaves_like "instance method" do
      let(:method) { :versions }
    end

    context "with versions" do
      let(:versions_count) { 5 }
      let(:piece) { FactoryGirl.create :piece, versions_count: versions_count }

      it "returns the correct number of versions" do
        subject.versions.count.should == versions_count
      end
    end

    context "with no versions" do
      let(:piece) { FactoryGirl.create :piece, versions_count: 0 }
      it "is empty" do
        subject.versions.should be_empty
      end
    end
  end

  describe "#drafts" do
    it_behaves_like "instance method" do
      let(:method) { :drafts }
    end

    let(:versions_count) { 5 }
    let(:piece) { FactoryGirl.create :piece, versions_count: versions_count }

    context "with no drafts" do
      specify "#drafts is empty" do
        subject.drafts.should be_empty
      end
    end

    context "with drafts" do
      specify "#drafts contains all the drafts" do
        drafts = []
        piece.versions.each do |v|
          drafts << create_draft(v)
        end

        subject.drafts.should == drafts
      end
    end
  end

  describe "#current_version" do
    it_behaves_like "instance method" do
      let(:method) { :current_version }
    end

    it "is the last item in #versions" do
      subject.current_version.should == subject.versions.last
    end
  end

  describe "#title" do
    subject { piece.title }

    it_behaves_like "instance method" do
      let(:method) { :title }
    end

    context "with a version" do
      it "is the current version's title" do
        should == piece.current_version.title
      end
    end

    context "with no versions" do
      it "is nil" do
        piece.versions.destroy_all

        should be_nil
      end
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

  context "with a piece" do
    before :each do
      @versions_count = 2
      @piece = FactoryGirl.build_stubbed :piece, versions_count: @versions_count
    end

    describe "instance methods" do
      subject { @piece }

      methods = [ :short_title ]
      methods.each do |m|
        it "responds to ##{m}" do
          should respond_to m
        end
      end

      context "with a saved piece" do
        before :each do
          @piece = FactoryGirl.create :piece, versions_count: @versions_count 
        end

        subject { @piece }

        specify "#short_title gives the current version's short title" do
          subject.short_title == subject.current_version.short_title
        end
      end

      context "with a piece with no versions" do
        before :each do
          @no_versions_piece = FactoryGirl.create :piece, versions_count: 0
        end

        subject { @no_versions_piece }

        specify "#short_title is nil" do
          subject.short_title.should be_nil
        end
      end
    end

    it "has a user" do
      @piece.user.should_not be_nil
    end

    it "is not valid without a user" do
      no_user_piece = FactoryGirl.build_stubbed :piece, user: nil
      no_user_piece.should_not be_valid
    end

    describe "creating a new version" do
      it "increases the size of the versions collection by 1" do
        piece = FactoryGirl.create :piece
        expect do
          FactoryGirl.create :version, piece: piece
          piece.reload
        end.to change{ piece.versions.length }.by 1
      end
    end

    describe "a new version" do
      before :each do
        @piece = FactoryGirl.create :piece
        @new_version = FactoryGirl.create :version, piece: @piece
      end

      it "saves the new version" do
        @new_version.should_not be_a_new_record
      end

      it "has piece as its piece" do
        @new_version.piece.should == @piece
      end

      it "adds the new version to the versions collection" do
        @piece.versions.should include @new_version
      end
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
