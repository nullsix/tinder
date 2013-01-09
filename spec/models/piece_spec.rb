require 'spec_helper'

describe Piece do
  describe "instance methods" do
    let(:piece) { Piece.new }

    it "should respond to #versions" do
      piece.should respond_to(:versions)
    end

    it "should respond to #current_version" do
      piece.should respond_to(:current_version)
    end
  end
end
