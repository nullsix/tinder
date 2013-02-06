require 'spec_helper'

describe Piece do

  it "has a valid factory" do
    FactoryGirl.build_stubbed(:piece).should be_valid
  end
  
  before :all do
    @versions_count = 2
    @piece = build_stubbed :piece, versions_count: @versions_count
  end

  describe "instance methods" do
    subject { @piece }

    [:versions, :current_version, :title, :content, :blurb].each do |m|
      it "responds to ##{m}" do
        should respond_to m
      end
    end

    context "with a saved piece" do
      before :each do
        @saved_piece = create :piece, versions_count: @versions_count
      end

      subject { @saved_piece }

      it "has the correct number of versions" do
        subject.versions.length.should == @versions_count
      end

      it "has a #current_version is the last item in #versions" do
        subject.current_version.should == subject.versions.last
      end

      specify "#title gives the current version's title" do
        subject.title.should == subject.current_version.title
      end

      specify "#content gives the current version's content" do
        subject.content.should == subject.current_version.content
      end

      specify "#blurb gives the current version's content" do
        subject.blurb.should == subject.current_version.blurb
      end
    end

    context "with a piece with no versions" do
      before :each do
        @no_versions_piece = create :piece, versions_count: 0
      end

      subject { @no_versions_piece }

      specify "#title is nil" do
        subject.title.should be_nil
      end

      specify "#content is nil" do
        subject.content.should be_nil
      end

      specify "#blurb is nil" do
        subject.blurb.should be_nil
      end
    end
  end

  it "has a user" do
    @piece.user.should_not be_nil
  end

  it "is not valid without a user" do
    no_user_piece = build_stubbed :piece, user: nil
    no_user_piece.should_not be_valid
  end

  describe "creating a new version" do
    it "increases the size of the versions collection by 1" do
      piece = create :piece
      expect do
        create :version, piece: piece
        piece.reload
      end.to change{ piece.versions.length }.by 1
    end
  end

  describe "a new version" do
    before :all do
      @piece = create :piece
      @new_version = create :version, piece: @piece
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

    it "sets the new version as the current version" do
      piece = create :piece
      new_version = create :version, piece: piece
      piece.current_version.should == new_version
    end
  end
end
