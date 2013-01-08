class PiecesController < ApplicationController
  before_filter :signed_in_user

  def index
    @pieces = current_user.pieces
  end

  def new
    redirect_to root_url if !current_user

    @piece = Piece.new
  end

  def create
    @piece = current_user.pieces.build(params[:piece])
    if @piece.save
      redirect_to piece_path(@piece)
    else
      render 'piece/new', notice: 'Sorry, this was not a valid piece.'
    end
  end

  def show
    @piece = Piece.find_by_id params[:id]
  end
end
