require 'spec_helper'

describe Version do
  def version
    build_stubbed :version
  end

  subject { version }

  it "has a valid factory" do
    should be_valid
  end
  
  describe "instance methods" do
    it { should respond_to(:title) }

    it { should respond_to(:content) }

    it { should respond_to(:piece) }

    describe "#title" do
      subject { version.title }

      it { should be_a(String) }
    end

    describe "#content" do
      subject { version.content }

      it { should be_a(String) }
    end
  end

  describe "validations" do
    describe "#title" do
      it "is not valid without a title" do
        version = build_stubbed :version, title: nil

        version.should_not be_valid
      end

      it "is not valid with an empty title" do
        version = build_stubbed :version, title: ""

        version.should_not be_valid
      end

      it "is valid with a title with a single character" do
        version = build_stubbed :version, title: "a"

        version.should be_valid
      end
      
      it "is valid with a non-blank title" do
        should be_valid
      end

      it "is valid with a title of 255 characters" do
        version = build_stubbed :version, title: "a" * 255

        version.should be_valid
      end

      it "is invalid with a title of more than 255 characters" do
        version = build_stubbed :version, title: "a" * 256

        version.should_not be_valid
      end
    end

    describe "#content" do
      it "is not valid without a content" do
        version = build_stubbed :version, content: nil

        version.should_not be_valid
      end

      it "is not valid with an empty content" do
        version = build_stubbed :version, content: ""

        version.should_not be_valid
      end

      it "is valid with a content with a single character" do
        version = build_stubbed :version, content: "a"

        version.should be_valid
      end
      
      it "is valid with a non-blank content" do
        should be_valid
      end

      it "is valid with a content of more than 255 characters" do
        version = build_stubbed :version, content: "a" * 10_000

        version.should be_valid
      end
    end
  end
end
