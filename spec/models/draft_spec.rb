# == Schema Information
#
# Table name: drafts
#
#  id         :integer          not null, primary key
#  number     :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  version_id :integer
#

require 'spec_helper'

describe Draft do
  it "has a valid factory" do
    FactoryGirl.build_stubbed(:draft).should be_valid
  end

  let(:draft) { FactoryGirl.build_stubbed :draft }

  subject { draft }

  describe "#version" do
    it_behaves_like "instance method" do
      let(:instance) { draft }
      let(:method) { :version }
    end

    specify do
      subject.version.should be_a Version
    end
  end

  describe "#number" do
    it_behaves_like "instance method" do
      let(:instance) { draft }
      let(:method) { :number }
    end

    specify do
      subject.number.should be_an Integer
    end
  end

  describe "#piece" do
    it_behaves_like "instance method" do
      let(:instance) { draft }
      let(:method) { :piece }
    end

    specify do
      subject.piece.should be_a Piece
    end
  end
end
