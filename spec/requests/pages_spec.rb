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

    describe "when not logged in" do

      it "should show a link to 'Sign in with Google'" do
        should have_link('Sign in with Google')
      end
    end
  end
end

