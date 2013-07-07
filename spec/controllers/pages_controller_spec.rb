require 'spec_helper'

describe PagesController do
  describe "GET index" do
    before :each do
      get :index
    end

    it "renders the #index view" do
      should render_template :index
    end
  end
end
