class DraftsController < ApplicationController
  before_filter :require_signed_in_user, only: :create
  before_filter :get_piece
  before_filter :require_owner, only: :create

  def index
    redirect_to history_piece_path id: @piece.id
  end

  def create
    if @piece.create_draft
      @draft = @piece.drafts.first
      redirect_to piece_draft_path(piece_id: @piece, id: @draft.number), notice: "Draft has been successfully created. You can now share this page's link with others and they will be able to read this draft!"
    end
  end

  def show
    @draft = @piece.drafts.find_by number: params[:id]

    unless @draft
      redirect_to piece_path params[:piece_id]
    end
  end

  private
    def get_piece
      @piece = Piece.find params[:piece_id]

    # The piece either doesn't exist or doesn't belong to this user.
    rescue ActiveRecord::RecordNotFound
      redirect_to pieces_path
    end

    def require_owner
      unless owner_is_logged_in? @piece.user
        redirect_to pieces_path
        return
      end
    end
end
