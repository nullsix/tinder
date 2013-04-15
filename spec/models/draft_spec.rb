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
  
  describe "instance methods" do 
    methods = [ :version, :piece, :number ]
    methods.each do |m|
      it "responds to #{m}" do
        should respond_to m
      end
    end
    
    context "with a draft" do
      subject { FactoryGirl.build_stubbed :draft }

      specify do
        subject.version.should be_a Version
      end

      specify do
        subject.number.should be_an Integer
      end

      specify do
        subject.piece.should be_a Piece
      end
    end
  end
end
