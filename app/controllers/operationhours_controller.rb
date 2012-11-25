class OperationhoursController < ApplicationController
  # GET /operationhours
  # GET /operationhours.json
  #include Sdata
  
  before_filter :getscheduleparameters

  def getscheduleparameters
      @maxschedulerId = current_user.maxscheduler_id
      @siteId = current_user.currentSite
      @boardId = current_user.currentBoard
      @configurationScreen = true
  end  

  def index
    @operationhours = Operationhour.where("maxscheduler_id = ?", @maxschedulerId)
    @operationhour = Operationhour.new

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @operationhours }
    end
  end

  # GET /operationhours/1
  # GET /operationhours/1.json
  def show
    @operationhour = Operationhour.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @operationhour }
    end
  end

  # GET /operationhours/new
  # GET /operationhours/new.json
  def new
    @operationhour = Operationhour.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @operationhour }
    end
  end

  # GET /operationhours/1/edit
  def edit
    @operationhour = Operationhour.find(params[:id])
  end

  # POST /operationhours
  # POST /operationhours.json
  def create
    @operationhour = Operationhour.new(params[:operationhour])

    respond_to do |format|
      if @operationhour.save
        format.html { redirect_to @operationhour, notice: 'Operationhour was successfully created.' }
        format.json { render json: @operationhour, status: :created, location: @operationhour }
      else
        format.html { render action: "new" }
        format.json { render json: @operationhour.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /operationhours/1
  # PUT /operationhours/1.json
  def update
    @operationhour = Operationhour.find(params[:id])

    respond_to do |format|
      if @operationhour.update_attributes(params[:operationhour])
        format.html { redirect_to @operationhour, notice: 'Operationhour was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @operationhour.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /operationhours/1
  # DELETE /operationhours/1.json
  def destroy
    @operationhour = Operationhour.find(params[:id])
    @operationhour.destroy

    respond_to do |format|
      format.html { redirect_to operationhours_url }
      format.json { head :no_content }
    end
  end
end
