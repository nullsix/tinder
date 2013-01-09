class VersionsController < ApplicationController
  respond_to :html
  before_filter :find_piece

  def index
    @version = @piece.versions.find params[:version_id]
  end

  def new
    @version = @piece.versions.build
    respond_with @version
  end

  def create
    @version = @piece.versions.build(params[:version])
    if @version.save
      redirect_to @piece
    else
      render action: :new
      #TODO: What to do here?!
    end
  end

  def show
    @version = @piece.versions.find params[:id]
  end

  private
    def find_piece
      @piece = Piece.find params[:piece_id]
    end
end
