class MaxschedulersController < ApplicationController
  # GET /maxschedulers
  # GET /maxschedulers.json
  include Sdata
  
  before_filter :getscheduleparameters

  def getscheduleparameters
      @maxschedulerId = current_user.maxscheduler_id
      @siteId = current_user.currentSite
      @boardId = current_user.currentBoard
      @configurationScreen = true
  end  

  
  def set
      session[:maxscheduler] = params[:id]
      redirect_to '/scheduler/showData'
  end
  
  def index
    @maxschedulers = Maxscheduler.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @maxschedulers }
    end
  end

  # GET /maxschedulers/1
  # GET /maxschedulers/1.json
  def show
    @maxscheduler = Maxscheduler.find(params[:id])
    session[:maxscheduler] = @maxscheduler
            
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @maxscheduler }
    end
  end

  # GET /maxschedulers/new
  # GET /maxschedulers/new.json
  def new
    @maxscheduler = Maxscheduler.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @maxscheduler }
    end
  end

  # GET /maxschedulers/1/edit
  def edit
    @maxscheduler = Maxscheduler.find(params[:id])
  end

  # POST /maxschedulers
  # POST /maxschedulers.json
  def create
    @maxscheduler = Maxscheduler.new(params[:maxscheduler])

    respond_to do |format|
      if @maxscheduler.save
        format.html { redirect_to @maxscheduler, notice: 'Maxscheduler was successfully created.' }
        format.json { render json: @maxscheduler, status: :created, location: @maxscheduler }
      else
        format.html { render action: "new" }
        format.json { render json: @maxscheduler.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /maxschedulers/1
  # PUT /maxschedulers/1.json
  def update
    @maxscheduler = Maxscheduler.find(params[:id])

    respond_to do |format|
      if @maxscheduler.update_attributes(params[:maxscheduler])
        format.html { redirect_to @maxscheduler, notice: 'Maxscheduler was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @maxscheduler.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /maxschedulers/1
  # DELETE /maxschedulers/1.json
  def destroy
    @maxscheduler = Maxscheduler.find(params[:id])
    @maxscheduler.destroy

    respond_to do |format|
      format.html { redirect_to maxschedulers_url }
      format.json { head :no_content }
    end
  end
  
   private
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
  
end
