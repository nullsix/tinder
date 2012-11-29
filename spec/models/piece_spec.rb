require 'spec_helper'

describe Piece do
  describe "instance methods" do
    let(:piece) { Piece.new }

    it "should respond to .content" do
      piece.should respond_to(:content)
    end

    it "should respond to .title" do
      piece.should respond_to(:title)
    end
  end
end
