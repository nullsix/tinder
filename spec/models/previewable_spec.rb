describe Previewable do
  describe "BLURB_LENGTH" do
    it "is a constant" do
      should be_const_defined :BLURB_LENGTH
    end
  end

  describe "SHORT_TITLE_LENGTH" do
    it "is a constant" do
      should be_const_defined :SHORT_TITLE_LENGTH
    end
  end

  describe "#preview" do
    before :each do
      @object = Object.new
      @object.extend Previewable
    end

    context "when passed nil" do
      it "is nil" do
        @object.preview(nil, 10).should be_nil
      end
    end

    context "with a string shorter than length" do
      it "is the string" do
        string = "Hey there"
        length = string.length + 1
        returned_string = @object.preview(string, length)
        returned_string.should == string
      end
    end

    context "with a string longer than length" do
      it "returns a preview of the string" do
        string = "Hey there"
        length = string.length - 1
        returned_string = @object.preview(string, length)
        expected_string = "Hey t..."
        returned_string.should == expected_string
      end
    end
  end
end
