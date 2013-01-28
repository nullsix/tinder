require 'spec_helper'

feature "Layouts" do
  subject { page }

  background do
    visit root_path
  end

  describe "Home page" do
    it "should have a header" do
      should have_selector 'header'
    end

    it "should have a footer" do
      should have_selector 'footer'
    end

    describe "Header" do
      subject { find 'header' }

      it "should have a link to tinder" do
        should have_link 'tinder', href: root_path
      end
    end

    describe "Footer" do
      subject { find 'footer' }

      it "should have a link to nullsix" do
        should have_link 'nullsix', href: "http://www.nullsix.com"
      end
    end
  end

end

