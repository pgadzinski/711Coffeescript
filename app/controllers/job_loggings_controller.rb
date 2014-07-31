class JobLoggingsController < ApplicationController

  before_filter :getscheduleparameters

  def getscheduleparameters
      @maxschedulerId = current_user.maxscheduler_id
      @siteId = current_user.currentSite
      @boardId = current_user.currentBoard
      @attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)
  end

  # GET /job_loggings
  # GET /job_loggings.json
  def index
    @job_loggings = JobLogging.where("maxscheduler_id = ?", @maxschedulerId)
    @job_loggings = @job_loggings.order("created_at DESC")

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @job_loggings }
    end
  end

  # GET /job_loggings/1
  # GET /job_loggings/1.json
  def show
    @job_logging = JobLogging.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @job_logging }
    end
  end

  # GET /job_loggings/new
  # GET /job_loggings/new.json
  def new
    @job_logging = JobLogging.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @job_logging }
    end
  end

  # GET /job_loggings/1/edit
  def edit
    @job_logging = JobLogging.find(params[:id])
  end

  # POST /job_loggings
  # POST /job_loggings.json
  def create
    @job_logging = JobLogging.new(params[:job_logging])

    respond_to do |format|
      if @job_logging.save
        format.html { redirect_to @job_logging, notice: 'Job logging was successfully created.' }
        format.json { render json: @job_logging, status: :created, location: @job_logging }
      else
        format.html { render action: "new" }
        format.json { render json: @job_logging.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /job_loggings/1
  # PUT /job_loggings/1.json
  def update
    @job_logging = JobLogging.find(params[:id])

    respond_to do |format|
      if @job_logging.update_attributes(params[:job_logging])
        format.html { redirect_to @job_logging, notice: 'Job logging was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @job_logging.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /job_loggings/1
  # DELETE /job_loggings/1.json
  def destroy
    @job_logging = JobLogging.find(params[:id])
    @job_logging.destroy

    respond_to do |format|
      format.html { redirect_to job_loggings_url }
      format.json { head :no_content }
    end
  end
end
