class PiecesController < ApplicationController
  respond_to :html
  before_filter :require_signed_in_user

  before_filter :get_piece, except: [:index, :new, :create]

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
    @version = @piece.current_version
  end

  def update
    @version = @piece.versions.build params[:version]

    if @piece.save
      redirect_to @piece, notice: "Piece was successfully updated."
    else
      render action: 'edit'
    end
  end

  def show
  end

  def destroy
    redirect_to root_url unless @piece && @piece.user = current_user

    @piece.destroy

    redirect_to pieces_path, notice: "Piece was successfully deleted."
  end

  private
  def get_piece
    @piece = current_user.pieces.find params[:id]
  
  # The piece either doesn't exist or doesn't belong to this user.
  rescue ActiveRecord::RecordNotFound
    redirect_to pieces_path
  end
end
