require 'spec_helper'

describe "Pages" do

  describe "Index" do

    it "should have the title tinder" do
      visit "pages#index"
      page.should have_selector('title', text: 'tinder')
    end
  end
end

