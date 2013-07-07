require 'spec_helper'

describe "pages/index" do
  before :each do
    view.stub(:current_user)
  end

  describe "when not logged in" do
    before :each do
      view.stub(:signed_in?).and_return(false)
      render
    end

    it "should show a link to 'Sign in with Google'" do
      rendered.should have_content('Sign in with Google')
    end
  end

  describe "when logged in" do
    before :each do
      view.stub(:signed_in?).and_return(true)
      render
    end

    it "shouldn't show sign in link" do
      rendered.should_not have_content("Sign in with Google")
    end
  end
end

