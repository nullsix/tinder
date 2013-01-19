require 'spec_helper'

describe Piece do
  def versions_count; 2 end
  
  def piece
    build_stubbed(:piece, versions_count: versions_count)
  end

  describe "instance methods" do
    describe "#versions" do
      it "responds to #versions" do
        piece.should respond_to(:versions)
      end
      
      it "has the correct number of versions" do
        piece = create(:piece, versions_count: versions_count)
        piece.versions.length.should == versions_count
      end
    end

    describe "#current_version" do
      it "responds to #current_version" do
        piece.should respond_to(:current_version)
      end

      it "has a #current_version is the last item in #versions" do
        piece.current_version.should ==(piece.versions.last)
      end
    end
  end

  it "has a user" do
    piece.user.should_not be_nil
  end

  it "is not valid without a user" do
    no_user_piece = build_stubbed(:piece, user: nil)
    no_user_piece.should_not be_valid
  end

  describe "creating a new version" do
    it "increases the size of the versions collection by 1" do
      piece = create(:piece)
      expect{create(:version, piece: piece); piece.reload}.to change{piece.versions.length}.by(1)
    end
  end

  describe "a new version" do
    let(:piece) { create(:piece) }
    let(:new_version) { create(:version, piece: piece) }

    it "saves the new version" do
      new_version.should_not be_a_new_record
    end

    it "has piece as its piece" do
      new_version.piece.should ==(piece)
    end

    it "adds the new version to the versions collection" do
      piece.versions.should include(new_version)
    end

    it "sets the new version as the current version" do
      piece = create :piece
      new_version = create :version, piece: piece
      piece.current_version.should ==(new_version)
    end
  end
end
