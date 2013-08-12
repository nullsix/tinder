class PiecesController < ApplicationController
  respond_to :html
  before_filter :require_signed_in_user, except: [ :history ]

  before_filter :get_piece, except: [ :index, :new, :create, :history ]

  def index
    @pieces = current_user.pieces.last_modified_first
  end

  def new
    @piece = Piece.new
  end

  def create
    @piece = current_user.pieces.build
    @piece.title = params[:piece][:title]
    @piece.content = params[:piece][:content]

    if @piece.save
      redirect_to @piece, notice: "Piece was successfully created."
    else
      render action: 'new'
    end
  end

  def edit
  end

  def update
    @piece.title = params[:piece][:title]
    @piece.content = params[:piece][:content]

    if @piece.changed?
      if @piece.save
        redirect_to @piece, notice: "Piece was successfully updated."
      else
        render action: 'edit'
      end
    else
      redirect_to @piece, notice: "Piece was already saved."
    end
  end

  def show
  end

  def destroy
    @piece.destroy

    redirect_to pieces_path, notice: "Piece was successfully deleted."
  end

  def history
    @piece = Piece.find params[:id]

    if owner_is_logged_in? @piece.user
      versions = @piece.versions
    else
      versions = @piece.versions.select{|v| !v.draft.nil? }
    end
    @versions = versions.reverse
  rescue ActiveRecord::RecordNotFound
    if current_user
      redirect_to pieces_path
    else
      redirect_to root_path
    end
  end

  private
    def get_piece
      @piece = current_user.pieces.find params[:id]

    # The piece either doesn't exist or doesn't belong to this user.
    rescue ActiveRecord::RecordNotFound
      redirect_to pieces_path
    end
end
