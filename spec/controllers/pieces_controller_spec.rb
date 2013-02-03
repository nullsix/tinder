require 'spec_helper'

shared_examples "an action assigning @piece" do
  describe "@piece" do
    subject { assigns :piece }

    it "is a Piece" do
      should be_a Piece
    end

    it "belongs to the logged in user" do
      subject.user.should eq @user
    end
  end
end

shared_examples "an action assigning @version" do
  describe "@version" do
    subject { assigns :version }

    it "is a Version" do
      should be_a Version
    end

    it "belongs to the piece being created" do
      subject.piece.should eq assigns(:piece)
    end
  end
end

private
  def piece_methods
    [
      { get:    :show    },
      { get:    :edit    },
      { put:    :update  },
      { delete: :destroy }
    ]
  end

public
  describe PiecesController do
    context "with no user logged in" do
      methods = [
        { put: :create },
        { get: :new    },
        { get: :index  }
      ]

      methods.each do |m|
        m.each do |verb, action|
          describe "#{verb.upcase} #{action}" do
            it "redirects to root_url" do
              self.send verb, action
              should redirect_to root_url
            end
          end
        end
      end

      context "where actions require a piece" do 
        before :all do
          @piece = create :piece
        end
        
        piece_methods.each do |m|
          m.each do |action, verb|
            describe "#{action.upcase} #{verb}" do
              it "redirects to root_url" do
                self.send action, verb, id: @piece.id
                should redirect_to root_url
              end
            end
          end
        end
      end
    end

    context "with a logged in user" do
      before :all do
        @user = FactoryGirl.create :user, pieces_count: 0
      end

      before :each do
        session[:user_id] = @user.id
      end

      context "where the piece belongs to the user" do
        before :all do
          @piece = FactoryGirl.create :piece, user_id: @user.id
        end

        describe "GET index" do
          before :each do
            get :index
          end

          describe "@pieces" do
            subject{ assigns :pieces }

            it "is an array of Pieces" do
              should eq [@piece]
            end

            it "belongs to the logged in user" do
              subject.each { |p| p.user.should eq @user }
            end
          end

          it "renders the #index view" do
            should render_template :index
          end
        end

        describe "GET new" do
          before :each do
            get :new
          end

          it_behaves_like "an action assigning @piece"

          specify "@piece is a new Piece" do
            assigns(:piece).should be_a_new_record
          end

          it_behaves_like "an action assigning @version"

          specify "@version is a new Version" do
            assigns(:version).should be_a_new_record
          end

          it "renders the #new view" do
            should render_template :new
          end
        end

        describe "POST create" do
          before :each do
            @piece_attr = FactoryGirl.attributes_for :piece, user_id: @user
            @version_attr = FactoryGirl.attributes_for :version, piece_id: @piece
            @valid_create =
              Proc.new { post :create, piece: @piece_attr, version: @version_attr }
          end

          context "with a valid version" do
            it "creates a new piece" do
              expect { @valid_create.call }.to change(Piece, :count).by 1
            end

            it "creates a new version" do
              expect { @valid_create.call }.to change(Version, :count).by 1
            end

            it "redirects to the piece just created" do
              @valid_create.call

              should redirect_to Piece.last
            end
          end

          context "with an invalid version" do
            before :each do
              @invalid_version_attr =
                FactoryGirl.attributes_for :invalid_version, piece_id: @piece
              @invalid_create =
                Proc.new {
                  post :create, piece: @piece_attr, version: @invalid_version_attr
                }
            end

            it "does not create a new piece" do
              expect { @invalid_create.call }.to_not change Piece, :count
            end
            
            it "does not create a new version" do
              expect { @invalid_create.call }.to_not change Version, :count
            end

            before :each do
              @invalid_create.call
            end

            it_behaves_like "an action assigning @piece"
            it_behaves_like "an action assigning @version"

            specify "@version has an error message" do
              assigns(:version).errors.should_not be_empty
            end

            it "renders the #new view" do
              should render_template :new
            end
          end
        end

        describe "GET edit" do
          before :each do
            get :edit, id: @piece
          end

          it "assigns the requested piece to @piece" do
            assigns(:piece).should eq @piece
          end

          it "assigns the piece's current version to @version" do
            assigns(:version).should eq @piece.current_version
          end

          it "renders the #edit view" do
            should render_template :edit
          end
        end

        describe "PUT update" do
          before :each do
            @piece_attr =
              FactoryGirl.attributes_for(
                :piece,
                piece_id: @piece,
                user_id: @user
              )
            @version_attr =
              FactoryGirl.attributes_for(
                :version,
                piece_id: @piece,
                title: "I like pie.",
                content: "La-de-da-de-da"
              )
          end

          context "with a valid piece" do
            context "with a valid version" do
              before :each do
                @valid_update =
                  Proc.new {
                    put :update,
                      id: @piece.id,
                      piece: @piece_attr,
                      version: @version_attr
                  }
              end

              it "creates a new version" do
                expect { @valid_update.call }.to change(Version, :count).by 1
              end

              it "associates the new version to the existing piece" do
                expect {
                  @valid_update.call
                  @piece.reload
                }.to change(@piece.versions, :count).by 1
              end

              before :each do
                @valid_update.call
              end

              it "locates the requested piece" do
                assigns(:piece).should eq @piece
              end

              specify "locastes the requested version" do
                assigns(:version).should eq Version.last
              end

              it "creates the version with the given attributes" do
                @piece.reload
                @piece.versions.last.title.should eq "I like pie."
                @piece.versions.last.content.should eq "La-de-da-de-da"
              end

              it "redirects to the piece" do
                should redirect_to @piece
              end
            end

            context "with an invalid version" do
              before :each do
                @invalid_version_attr =
                  FactoryGirl.attributes_for(
                    :invalid_version,
                    piece_id: @piece,
                    content: "La-de-da-de-da"
                  )
                @invalid_update =
                  Proc.new {
                    put :update,
                      id: @piece.id,
                      piece: @piece_attr,
                      version: @invalid_version_attr
                  }
              end

              it "does not create a new version" do
                expect{ @invalid_update.call }.not_to change Version, :count
              end

              before :each do
                @invalid_update.call
              end

              it "locates the requested piece" do
                assigns(:piece).should eq @piece
              end

              it_behaves_like "an action assigning @version"

              it "does not create a Version with the attributes" do
                piece = Piece.find assigns(:piece).id
                piece.versions.last.content.should_not eq @invalid_version_attr[:content]
              end

              it "re-renders the #edit view" do
                should render_template :edit
              end
            end
          end

          context "with an invalid piece" do
            before :each do
              @no_piece_update =
                Proc.new {
                  put :update,
                    id: -1,
                    piece: nil,
                    version: nil
                }
            end

            it "does not create a new version" do
              expect{ @no_piece_update.call }.not_to change(Version, :count)
            end

            before(:each) { @no_piece_update.call }
            it { should redirect_to pieces_url }
          end
        end

        describe "GET show" do
          before :each do
            get :show, id: @piece
          end

          it "assigns the requested piece to @piece" do
            assigns(:piece).should eq @piece
          end

          it "renders the #show view" do
            should render_template :show
          end
        end

        describe "DELETE destroy" do
          before :each do
            @valid_destroy = Proc.new{ delete :destroy, id: @piece.id }
          end

          it "deletes the piece" do
            expect{ @valid_destroy.call }.to change(Piece, :count).by -1
          end

          it "deletes the associated versions" do
            expect { @valid_destroy.call }.to change(Version, :count).
              by -1*@piece.versions.length
          end

          it "redirects to the pieces#index" do
            @valid_destroy.call
            should redirect_to pieces_url
          end
        end
      end

      context "where the piece doesn't belong to the user" do
        piece_methods.each do |m|
          m.each do |action, verb|
            describe "#{action.upcase} #{verb}" do
              before :each do
                @other_user = FactoryGirl.create :user, name: "Other"
                @others_piece = FactoryGirl.create :piece, user: @other_user
                FactoryGirl.create :version, title: "Other's piece", piece: @others_piece
              end

              it "doesn't allow access to a piece not belonging to the logged in user" do
                self.send action, verb, id: @others_piece.id

                should redirect_to pieces_url
              end
            end
          end
        end
      end
    end
  end
