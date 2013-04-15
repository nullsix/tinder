class PiecesController < ApplicationController
  respond_to :html
  before_filter :require_signed_in_user, except: [ :history ]

  before_filter :get_piece, except: [ :index, :new, :create, :history ]

  def index
    @pieces = current_user.pieces.last_modified_first
  end

  def new
    @piece = Piece.new
    @version = Version.new
  end

  def create
    @piece = current_user.pieces.build

    @version = build_version @piece, params[:version]

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
    original_version = @piece.current_version

    new_version = build_version @piece, params[:version]

    if version_has_changed?(original_version, new_version)
      @version = new_version

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

  def version_has_changed?(original_version, new_version)
    title_changed = original_version.title != new_version.title
    content_changed = original_version.content != new_version.content

    title_changed || content_changed
  end

  def title_or_default(title)
    if title.empty?
      "Untitled Piece"
    else
      title
    end
  end

  def build_version(piece, hash)
    version = piece.versions.build
    version.title = title_or_default hash[:title]
    version.content = hash[:content]
    version = set_version_number version
  end

  def set_version_number(version)
    version.number = version.piece.versions.count + 1
    version
  end
end
