require 'spec_helper'

describe "Pages" do

  describe "Index" do
    before do
      visit "pages#index"
    end

    subject { page }

    it "should have the title tinder" do
      should have_selector('title', text: 'tinder')
    end

    it "should not have a cusom page title" do
      should_not have_selector('title', text: "|")
    end
  end
end

