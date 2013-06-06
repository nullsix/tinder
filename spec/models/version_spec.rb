# == Schema Information
#
# Table name: versions
#
#  id         :integer          not null, primary key
#  title      :string(255)
#  content    :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  piece_id   :integer
#  number     :integer
#

require 'spec_helper'

shared_examples "is a string" do
  it { should be_a String }
end

describe Version do

  it "has a valid factory" do
    FactoryGirl.build_stubbed(:version).should be_valid
  end

  let(:piece) { FactoryGirl.create :piece }
  let(:version) { FactoryGirl.create :version, piece: piece }

  subject { version }

  describe "#piece" do
    subject { version.piece }

    it_behaves_like "instance method" do
      let(:instance) { version }
      let(:method) { :piece }
    end

    it { should be_a Piece }
  end

  describe "#draft" do
    subject { version.draft }

    it_behaves_like "instance method" do
      let(:instance) { version }
      let(:method) { :draft }
    end

    context "with a draft" do
      it "is a draft" do
        draft = Draft.new
        draft.version = version
        draft.number = 1
        draft.save
        version.draft.should == draft
      end
    end

    context "with no draft" do
      it "is nil" do
        version.draft.should be_nil
      end
    end
  end

  describe "#title" do
    subject { version.title}

    it_behaves_like "instance method" do
      let(:instance) { version }
      let(:method) { :title }
    end

    it { should be_a String }
  end

  describe "#short_title" do
    subject { version.short_title}

    it_behaves_like "instance method" do
      let(:instance) { version }
      let(:method) { :short_title }
    end

    it { should be_a String }
  end

  describe "#content" do
    subject { version.content}

    it_behaves_like "instance method" do
      let(:instance) { version }
      let(:method) { :content }
    end

    it { should be_a String }
  end

  describe "#blurb" do
    subject { version.blurb}

    it_behaves_like "instance method" do
      let(:instance) { version }
      let(:method) { :blurb }
    end

    it { should be_a String }
  end

  describe "#number" do
    subject { version.number}

    it_behaves_like "instance method" do
      let(:instance) { version }
      let(:method) { :number }
    end
  end

  describe "validations" do
    describe "#title" do
      it "is valid without a title" do
        version = build_stubbed :version, title: nil

        version.should be_valid
      end

      it "is valid with an empty title" do
        version = build_stubbed :version, title: ""

        version.should be_valid
      end

      it "is valid with a title with a single character" do
        version = build_stubbed :version, title: "a"

        version.should be_valid
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
      it "is valid without a content" do
        version = build_stubbed :version, content: nil

        version.should be_valid
      end

      it "is valid with an empty content" do
        version = build_stubbed :version, content: ""

        version.should be_valid
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

    describe "#piece" do
      it "is not valid without a piece" do
        version = build_stubbed :version, piece: nil
        version.should_not be_valid
      end

      it "is valid with a piece" do
        @version.should be_valid
      end
    end

    describe "#blurb" do
      context "with a content whose size is > 50" do
        before :each do
          @version = build_stubbed :version, content: "a"*51
        end

        subject { @version }

        specify "has a blurb of 50 characters" do
          subject.blurb.length.should == 50
        end

        specify "has first 47 characters of the string" do
          subject.blurb[0..46].should == "a"*47
        end

        specify "has '...' as last 3 characters" do
          subject.blurb[-3..-1].should == "..."
        end
      end

      context "with a content whose size is 50 or less" do
        before :each do
          @version = build_stubbed :version, content: "a"*50
        end

        subject { @version }

        specify "has a blurb which equals the content" do
          subject.blurb.should == @version.content
        end
      end
    end

    describe "#short_title" do
      context "with a title whose size is > 30" do
        before :each do
          @version = build_stubbed :version, title: "a"*31
        end

        subject { @version }

        specify "has a short_title of 30 characters" do
          subject.short_title.length.should == 30
        end

        specify "has first 27 characters of the title" do
          subject.short_title[0..26].should == "a"*27
        end

        specify "has '...' as the last 3 characters" do
          subject.short_title[-3..-1].should == "..."
        end
      end

      context "with a title whose size is 30 or less" do
        before :each do
          @version = build_stubbed :version, title: "a"*30
        end

        subject { @version }

        specify "has a short_title which equals the title" do
          subject.short_title.should == @version.title
        end
      end
    end

    describe "#number" do
      context "with a number < 1" do
        it "is invalid" do
          version = build_stubbed :version, number: rand(-5..0)
          version.should_not be_valid
        end
      end

      context "with a number >= 1" do
        it "is valid" do
          version = build_stubbed :version, number: rand(1..100)
          version.should be_valid
        end
      end
    end
  end
end
