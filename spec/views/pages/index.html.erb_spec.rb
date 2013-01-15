require 'spec_helper'

describe "pages/index" do
  before :each do
    view.stub(:current_user)
    render
  end

  describe "when not logged in" do
    it "should show a link to 'Sign in with Google'" do
      rendered.should have_content('Sign in with Google')
    end
  end
end

