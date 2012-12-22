class JobsController < ApplicationController
  #include Sdata
  
  before_filter :getscheduleparameters

  def getscheduleparameters
      @maxschedulerId = current_user.maxscheduler_id
      @siteId = current_user.currentSite
      @boardId = current_user.currentBoard
      @attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)
  end  

  # GET /jobs
  # GET /jobs.json
  def index
    @jobs = Job.where("maxscheduler_id = ?", @maxschedulerId)
    
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
    @attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)
  end

  # POST /jobs
  # POST /jobs.json
  def create
    print params
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

  #POST /jobs/async_create
  def async_create
    @job = Job.new
    i=1
    for key, val in params[:job] do
      print val
      at = "attr"+i.to_s #this shit is hacks yo, change your model!
      @job[at] = val
      i=i+1
    end

    @job.user_id = current_user.id
    @job.maxscheduler_id = @maxschedulerId
    @job.site_id = @siteId
    @job.resource_id = 'none' #why are we mixing types here... none or 1,2,3,... why not 0,1,2,3?
    @job.schedDateTime = Time.now
    @job.schedPixelVal = 0
    
    if @job.save(:validate => true)
      print @job
      render :json => params
    else
      render json: @job.errors, status: :unprocessable_entity
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
    @operationhours = Operationhour.where("maxscheduler_id = ?", @maxschedulerId)
    @site = Site.find(@siteId)
    @rowHeight = @site.rowHeight.to_i
    @rowTimeIncrement = (@site.rowTimeIncrement).to_f
    @pixelValue = @job.schedPixelVal
    
    #Large chunk of code needed to calculate job time based on operation hours. 

    @numOfWeeks = ((@site.numberOfRows).to_i)
    @schedStartDate = current_user.schedStartDate.to_time
    #@schedStartDate = @schedStartDate.getlocal(current_user.timeZone)           # time for the top of the schedule
    @currentDay = @schedStartDate
    @rowCounter = 0
    @dateHash = Hash.new
 
    #Create hash that has the date/time data. Used for look up of pixel value matching to correct date/time. 
    #This is done by finding the row the job is one and looking up the date. The remainder is just the position within the row

      for j in 0..@numOfWeeks
        @weekStartDate = @schedStartDate + (j.to_i * 7 * 24 * 3600)
        @operationhours.each do | entry |
            @currentDay = @weekStartDate + ((entry.dayOfTheWeek.to_i) * 24 *3600)
            @time = @currentDay + (entry.start.to_i * 3600)      
            
            for i in 0..(entry.end.to_i)
                @dateHash[@rowCounter.to_s] = @time.to_s
                @time = @time + (@rowTimeIncrement * 3600)
                @rowCounter = @rowCounter + 1
            end
        end
      end

    @row = (@pixelValue.to_i) / (@rowHeight.to_i)
    @timeOfRow = @dateHash[@row.to_s]
    @secondsInRow = ((@pixelValue.to_i).fdiv(@rowHeight).abs.modulo(1)) * (@rowTimeIncrement * 3600)
    
    @jobTime = (@timeOfRow.to_time) + (@secondsInRow.to_i)
  
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
