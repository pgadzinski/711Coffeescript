class UsersController < ApplicationController
  # GET /users
  # GET /users.json

  before_filter :getscheduleparameters

  def getscheduleparameters
      @maxschedulerId = current_user.maxscheduler_id
      @siteId = current_user.currentSite
      @boardId = current_user.currentBoard
      @configurationScreen = true
  end  

  #Method to set the Site for a user and store value in the database. Done because session cookies weren't reliable
  def setSite
      current_user.currentSite = params[:id]
      current_user.save(:validate => false)
      sign_in current_user
      redirect_to '/scheduler/showData'
  end

  #Method to set the Board for a user and store value in the database. Done because session cookies weren't reliable
  def setBoard
      current_user.currentBoard = params[:id]
      current_user.save(:validate => false)
      sign_in current_user
      redirect_to '/scheduler/showData'
  end

  def index
    @maxschedulerId = current_user.maxscheduler_id
    @siteId = session[:site]
    @boardId = session[:board]
    @users = User.where("maxscheduler_id = ?", @maxschedulerId)
    @user = User.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
        
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
	       sign_in @user
        flash[:success] = "Welcome to MaxSchedulerWeb"
	       format.html { redirect_to @user, notice: 'User was successfully created.' }
         format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    @user = User.find(params[:id])

    respond_to do |format|
      if @user.update_attributes(params[:user])
        sign_in @user
        format.html { redirect_to @user, notice: 'User was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user = User.find(params[:id])
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end
end
