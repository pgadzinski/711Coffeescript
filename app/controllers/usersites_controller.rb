class UsersitesController < ApplicationController
  # GET /usersites
  # GET /usersites.json
  include Sdata
  
  before_filter :getscheduleparameters

  def getscheduleparameters
      @maxschedulerId = current_user.maxscheduler_id
      @siteId = current_user.currentSite
      @boardId = current_user.currentBoard
      @configurationScreen = true
  end  

  def index
    @usersites = Usersite.where("maxscheduler_id = ?", @maxschedulerId)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @usersites }
    end
  end

  # GET /usersites/1
  # GET /usersites/1.json
  def show
    @usersite = Usersite.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @usersite }
    end
  end

  # GET /usersites/new
  # GET /usersites/new.json
  def new
    @usersite = Usersite.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @usersite }
    end
  end

  # GET /usersites/1/edit
  def edit
    @usersite = Usersite.find(params[:id])
  end

  # POST /usersites
  # POST /usersites.json
  def create
    @usersite = Usersite.new(params[:usersite])

    respond_to do |format|
      if @usersite.save
        format.html { redirect_to @usersite, notice: 'Usersite was successfully created.' }
        format.json { render json: @usersite, status: :created, location: @usersite }
      else
        format.html { render action: "new" }
        format.json { render json: @usersite.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /usersites/1
  # PUT /usersites/1.json
  def update
    @usersite = Usersite.find(params[:id])

    respond_to do |format|
      if @usersite.update_attributes(params[:usersite])
        format.html { redirect_to @usersite, notice: 'Usersite was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @usersite.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /usersites/1
  # DELETE /usersites/1.json
  def destroy
    @usersite = Usersite.find(params[:id])
    @usersite.destroy

    respond_to do |format|
      format.html { redirect_to usersites_url }
      format.json { head :no_content }
    end
  end
end
