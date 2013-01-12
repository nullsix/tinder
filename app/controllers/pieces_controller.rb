class PiecesController < ApplicationController
  respond_to :html
  before_filter :signed_in_user

  def index
    @pieces = current_user.pieces
  end

  def new
    @piece = current_user.pieces.build
    @version = @piece.versions.build
  end

  def create
    @piece = current_user.pieces.build params[:piece]
    @version = @piece.current_version
    if @piece.save
      redirect_to piece_path(@piece)
    else
      render 'piece/new', notice: 'Sorry, this was not a valid piece.'
    end
  end

  def edit
    get_piece
    @version = @piece.current_version
  end

  def update
    get_piece
    # The form actually contains the version information we want, but
    # it's formatted as if we are going to update the version. Since
    # we're creating a new version instead of modifying an existing
    # one, we have to dig into the params hash to get the version
    # data to use to build a new version object.
    @version = @piece.versions.build params[:piece][:versions_attributes]["0"]

    if @piece.save
      redirect_to piece_path(@piece)
    else
      render 'piece/edit', notice: "Sorry, this was not a valid piece."
    end
  end

  def show
    get_piece
  end

  def destroy
    get_piece

    redirect_to root_url unless @piece && @piece.user = current_user

    @piece.destroy

    redirect_to pieces_path
  end

  private
  def get_piece
    @piece = current_user.pieces.find params[:id]
  end
end
