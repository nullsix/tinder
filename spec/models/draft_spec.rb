# == Schema Information
#
# Table name: drafts
#
#  id         :integer          not null, primary key
#  number     :integer
#  piece_id   :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'spec_helper'

describe Draft do
  it "has a valid factory" do
    FactoryGirl.build_stubbed(:draft).should be_valid
  end
  
  describe "instance methods" do 
    methods = [ :piece, :number ]
    methods.each do |m|
      it "responds to #{m}" do
        should respond_to m
      end
    end
  end
end
