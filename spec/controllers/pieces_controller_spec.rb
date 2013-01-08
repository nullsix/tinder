require 'spec_helper'

describe PiecesController do
  describe "GET new" do
    before :each do
      get :new
    end

    describe "user not logged in" do
      specify { should redirect_to(root_path) }
    end
  end
end
