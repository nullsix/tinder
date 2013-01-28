require 'spec_helper'

feature "Session Management" do
  subject { page }
  context "when user is not logged in" do
    background { visit root_path }

    scenario "User sees link to log in" do
      should have_content "Sign in with Google"
    end

    scenario "User does not see a profile link" do
      should_not have_link "testerbob", href: "/profile"
    end

    scenario "User does not see Sign Out link" do
      should_not have_link "Sign Out", href: "/signout"
    end

    scenario "User logs in" do
      click_link "Sign in with Google"

      should have_link "testerbob", href: "/profile"
      should_not have_link "Sign in with Google"
    end
  end

  context "when user is logged in" do
    background do
      login_with_oauth
      visit root_path
    end

    scenario "User sees a Sign Out link" do
      should have_link "Sign Out", href: "/signout"
    end

    scenario "User sees a profile link" do
      should have_link "testerbob", href: "/profile"
    end

    scenario "User sees a pieces link" do
      should have_link "Pieces", href: "/pieces"
    end

    scenario "User logs out" do
      click_link "Sign Out"

      should have_link "Sign in with Google"
    end
  end
end
