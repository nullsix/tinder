require 'spec_helper'

describe "Layouts" do
  subject { page }
  before :each do
    visit '/'
  end

  describe "Home page" do
    it "should have a header" do
      should have_selector('header')
    end

    it "should have a footer" do
      should have_selector('footer')
    end

  end

  describe "Header" do
    let(:header) { find('header') }

    it "should have a link to tinder" do
      header.should have_link('tinder', href: root_path)
    end
  end

  describe "Footer" do
    let(:footer) { find('footer') }

    it "should have a link to nullsix" do
        footer.should have_link('nullsix', href: "http://www.nullsix.com")
    end
  end
end

