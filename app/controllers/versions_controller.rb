class VersionsController < ApplicationController
  respond_to :html
  before_filter :require_signed_in_user, :get_piece
  
  def index
    @versions = @piece.versions.reverse
  end

  def show
    @version = @piece.versions.find_by_number params[:id]
  end

  private
  def get_piece
    @piece = current_user.pieces.find params[:piece_id]
  
  # The piece either doesn't exist or doesn't belong to this user.
  rescue ActiveRecord::RecordNotFound
    redirect_to pieces_path
  end
end
