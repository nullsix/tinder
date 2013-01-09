class PiecesController < ApplicationController
  respond_to :html
  before_filter :signed_in_user

  def index
    @pieces = current_user.pieces
  end

  def new
    redirect_to root_url if !current_user

    @piece = Piece.new(user: current_user)
    @piece.save
    
    @version = @piece.versions.build
  end

  def create
    @piece = current_user.pieces.build(params[:piece])
    @version = @piece.versions.build params[:version]
    if @piece.save
      redirect_to piece_path(@piece)
    else
      render 'piece/new', notice: 'Sorry, this was not a valid piece.'
    end
  end

  def edit
    @piece = current_user.pieces.find(params[:id])
    @version = @piece.current_version
  end

  def update
    @piece = current_user.pieces.find(params[:id])
    @version = @piece.current_version
    #TODO: Have to do some more stuff here...
  end

  def show
    @piece = Piece.find params[:id]
  end

  def destroy
    @piece = Piece.find params[:id]

    redirect_to root_url unless @piece && @piece.user = current_user

    @piece.destroy

    redirect_to pieces_path
  end
end
