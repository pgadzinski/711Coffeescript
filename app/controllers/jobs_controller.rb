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

    #Set parameters for building the row to time convert hash
    @operationhours = Operationhour.where("maxscheduler_id = ?", @maxschedulerId)
    @site = Site.find(@siteId)
    @rowHeight = @site.rowHeight.to_i
    @rowTimeIncrement = (@site.rowTimeIncrement).to_f
    @pixelValue = @job.schedPixelVal
    @numOfWeeks = ((@site.numberOfWeeks).to_i) - 1
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
            @currenttime = @currentDay + (entry.start.to_i * 3600)      
              
            for i in 1..(entry.numberOfRows.to_i)
                @dateHash[@rowCounter.to_s] = @currenttime
                @currenttime = @currenttime + (@rowTimeIncrement * 3600)
                @rowCounter = @rowCounter + 1
            end
        end
      end

    @row = (@pixelValue.to_i) / (@rowHeight.to_i)
    @timeOfRow = @dateHash[@row.to_s]
    @secondsInRow = ((@pixelValue.to_i).fdiv(@rowHeight).abs.modulo(1)) * (@rowTimeIncrement * 3600)
    
    @jobTime = (@timeOfRow.to_time) + (@secondsInRow.to_i)

    #Set the board for a job based on the assigned resource
    @jobHash = params[:job]
    @resource_id = @jobHash["resource_id"]

    #if (@resource_id)
      @resource = Resource.find(@resource_id)
      @board_id = @resource.board_id
      @job.board = @board_id.to_s
    #end 

    @job.schedDateTime = @jobTime
    @job.save(:validate => false)

  end
      
  
  def update
    @job = Job.find(params[:id])

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

  def moveDown
    #A job id and value will be passed in. The purpose is to move this job to an later start time as well as all jobs underneath it. 
    @job = Job.find(params[:jobId])
    @moveAmount = params[:shiftAmount]
    @jobResource = @job.resource
    @jobStartTime = @job.schedDateTime
    @jobsToMove = Job.where("maxscheduler_id = ? and site_id = ? and resource_id = ? and schedDateTime >= ?", @maxschedulerId, @siteId, @jobResource, @jobStartTime)
    #@jobsToMove = Job.where("maxscheduler_id = ? and site_id = ? and resource_id = ?", @maxschedulerId, @siteId, @jobResource)

    #Set parameters for building the row to time convert hash
    @operationhours = Operationhour.where("maxscheduler_id = ?", @maxschedulerId)
    @site = Site.find(@siteId)
    @rowHeight = @site.rowHeight.to_i
    @rowTimeIncrement = (@site.rowTimeIncrement).to_f
    @pixelValue = @job.schedPixelVal
    @numOfWeeks = ((@site.numberOfWeeks).to_i) + 3
    @schedStartDate = current_user.schedStartDate.to_time
    #@schedStartDate = @schedStartDate.getlocal(current_user.timeZone)           # time for the top of the schedule
    @currentDay = @schedStartDate
    @rowCounter = 0
    @dateHash = Hash.new
 
    #Create hash that has the date/time data. Used for look up of pixel value matching to correct date/time. 
    #This is done by finding the row the job is one and looking up the date. The remainder is just the position within the row

    for j in -3..@numOfWeeks
      @weekStartDate = @schedStartDate + (j.to_i * 7 * 24 * 3600)
      @operationhours.each do | entry |
          @currentDay = @weekStartDate + ((entry.dayOfTheWeek.to_i) * 24 *3600)
          @currenttime = @currentDay + (entry.start.to_i * 3600)      
            
          for i in 1..(entry.numberOfRows.to_i)
              @dateHash[@rowCounter.to_s] = @currenttime
              @currenttime = @currenttime + (@rowTimeIncrement * 3600)
              @rowCounter = @rowCounter + 1
          end
      end
    end

    #Loop through the jobs to move
    @jobsToMove.each do |job|
              @jobStartTime = job.schedDateTime
              @jobStartTime = @jobStartTime.to_time
               
              #Searching loop to find the pixel value of a job
              @dateHash.each do | rowNumber , rowDataStart |
                               @rowNumber = rowNumber
                               @rowStartDateTime = rowDataStart
                               @rowEndDateTime = @rowStartDateTime + (@rowTimeIncrement * 3600)

                               if ((@rowStartDateTime <= @jobStartTime) && ( @jobStartTime <= @rowEndDateTime))
                                    @jobRowNumber = @rowNumber           
                                    @pixelValue = (@jobRowNumber.to_i) * @rowHeight
                                    @remainingTimeDifference = (@jobStartTime - @rowStartDateTime)
                                    @pixelValue = @pixelValue + (((@remainingTimeDifference.to_f) / (@rowTimeIncrement * 3600) ) * @rowHeight )
                               end #if
                               @moveAmountInPixels = (@moveAmount.to_f / @rowTimeIncrement) * @rowHeight
                               @newPixelValue = @pixelValue.to_i + @moveAmountInPixels
            end #end hash
            #Have the new pixel value. Now find the new time for that pixel value
            @row = (@newPixelValue.to_i) / (@rowHeight.to_i)
            @timeOfRow = @dateHash[@row.to_s]
            @secondsInRow = ((@pixelValue.to_i).fdiv(@rowHeight).abs.modulo(1)) * (@rowTimeIncrement * 3600)
            @jobTime = (@timeOfRow.to_time) + (@secondsInRow.to_i)
            job.schedDateTime = @jobTime
            job.save(:validate => false)
    end #job loop         

     respond_to do |format|
       if @job.update_attributes(params[:job])
         format.html { redirect_to "/scheduler/showData"}
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
