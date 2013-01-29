class PagesController < ApplicationController
  def index
    if current_user
      @piece = current_user.pieces.build
      @version = @piece.versions.build
    end
  end
end
