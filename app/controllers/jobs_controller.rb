class JobsController < ApplicationController
  include Sdata
  
  before_filter :getscheduleparameters

  def getscheduleparameters
      @maxschedulerId = current_user.maxscheduler_id
      @siteId = current_user.currentSite
      @boardId = current_user.currentBoard
  end  

  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = Job.where("maxscheduler_id = ? and site_id = ?", @maxschedulerId, @siteId)
    @attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @jobs }
    end
  end

  # GET /jobs/1
  # GET /jobs/1.json
  def show
    @job = Job.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @job }
    end
  end

  # GET /jobs/new
  # GET /jobs/new.json
  def new
    @job = Job.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @job }
    end
  end

  # GET /jobs/1/edit
  def edit
    @job = Job.find(params[:id])
  end

  # POST /jobs
  # POST /jobs.json
  def create
    @job = Job.new(params[:job])

    respond_to do |format|
      if @job.save
        format.html { redirect_to @job, notice: 'Job was successfully created.' }
        format.json { render json: @job, status: :created, location: @job }
      else
        format.html { render action: "new" }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /jobs/1
  # PUT /jobs/1.json
  def async_update
     #params :id
    #render :json => params
       
    render :json => params 
    
    @job = Job.find(params[:id])
    @job.update_attributes(params[:job])

    #Converting pixel values to UTC time
    @site = Site.find(@siteId)
    @rowHeight = (@site.rowHeight).to_f
    @rowTimeIncrement = (@site.rowTimeIncrement).to_f
    
    @time = Time.parse(current_user.schedStartDate).getutc
    @timeTop = @time.getlocal(current_user.timeZone)           # time for the top of the schedule
    
    @pixelValue = @job.schedPixelVal
    @diffInSeconds = (@pixelValue.to_f / @rowHeight) * (@rowTimeIncrement * 3600) 

    @jobTime = @timeTop + @diffInSeconds

    #binding.pry

    @job.schedDateTime = @jobTime
    @job.save(:validate => false)

  end
      
  
  def update
    @job = Job.find(params[:id])

    #binding.pry

    respond_to do |format|
      if @job.update_attributes(params[:job])
        format.html { redirect_to @job, notice: 'Job was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1
  # DELETE /jobs/1.json
  def destroy
    @job = Job.find(params[:id])
    @job.destroy

    respond_to do |format|
      format.html { redirect_to jobs_url }
      format.json { head :no_content }
    end
  end
end
