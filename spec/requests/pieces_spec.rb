require 'spec_helper'

describe "Pieces" do
  describe "New" do
    before do
      visit "pieces#new"
    end

    subject { page }

    describe "when a user is not logged in" do
      specify { current_path.should == root_path }
    end
  end
end
