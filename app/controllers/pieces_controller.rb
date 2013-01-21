class PiecesController < ApplicationController
  respond_to :html
  before_filter :require_signed_in_user

  def index
    @pieces = current_user.pieces
  end

  def new
    @piece = current_user.pieces.build
    @version = @piece.versions.build
  end

  def create
    @piece = current_user.pieces.build params[:piece]
    @version = @piece.versions.build params[:version]

    
    if @piece.save # @version is saved implicitly
      redirect_to @piece, notice: "Piece was successfully created."
    else
      render action: 'new'
    end
  end

  def edit
    get_piece
    @version = @piece.current_version
  end

  def update
    get_piece
    @version = @piece.versions.build params[:version]
    #TODO: We don't want to create a new version if it's the exact same as before. Can we enfore a uniqueness of title and content?

    if @piece.save
      redirect_to @piece, notice: "Piece was successfully updated."
    else
      render action: 'edit'
    end
  end

  def show
    get_piece
  end

  def destroy
    get_piece

    redirect_to root_url unless @piece && @piece.user = current_user

    @piece.destroy

    redirect_to pieces_path, notice: "Piece was successfully deleted."
  end

  private
  def get_piece
    @piece = current_user.pieces.find params[:id]
  end
end
