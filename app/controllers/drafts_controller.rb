class DraftsController < ApplicationController
  before_filter :require_signed_in_user, only: :create
  before_filter :get_piece
  before_filter :require_owner, only: :create

  def index
    redirect_to history_piece_path id: @piece.id
  end

  def create
    @draft = @piece.current_version.build_draft
    @draft.number = @piece.drafts.count + 1

    if @draft.save
      redirect_to piece_draft_path piece_id: @piece, id: @draft.number
    end
  end

  def show
    @draft = @piece.drafts.find_by_number params[:id]

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
