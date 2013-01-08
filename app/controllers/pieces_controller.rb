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
    version = Version.new title: params[:version][:title], content: params[:version][:content]
    @piece = current_user.pieces.build(params[:piece])
    @piece.versions << version
    if @piece.save
      redirect_to piece_path(@piece)
    else
      render 'piece/new', notice: 'Sorry, this was not a valid piece.'
    end
  end

  def show
    @piece = Piece.find_by_id params[:id]
  end

  def destroy
    @piece = Piece.find_by_id params[:id]

    redirect_to root_url unless @piece && @piece.user = current_user

    @piece.destroy

    redirect_to pieces_path
  end
end
