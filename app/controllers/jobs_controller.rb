class JobsController < ApplicationController
  #include Sdata
  
  before_filter :getscheduleparameters

  def getscheduleparameters
      @maxschedulerId = current_user.maxscheduler_id
      @siteId = current_user.currentSite
      @boardId = current_user.currentBoard
      @attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)
  end  

  after_filter :updateBoardTimeStamp
  #Implementing ScheduleTimeStamp server side here. Update the current Board to state a change has been made to the schedule. 
  def updateBoardTimeStamp
    @board = Board.find(@boardId)
    @board.scheduleTimeStamp = Time.now.to_s
    @board.save(:validate => false)
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

  # Ajax call from client to update job details covered actions: dropping job on schedule, job dropping to listview, re-scheduling job, editing details 
  def asyncUpdate
      
    render :json => params 
    
    @job = Job.find(params[:id])
    @jobOld = @job.dup                 #this is for logging, want to record before and after
    @job.update_attributes(params[:job])

    #Hacky bad code
    #Currently the UI gives back the index of the resource the job is in. It DOES NOT give the proper resource_id. 
    #This is code to get the resource_id from the resource index

    @jobHash = params[:job]
    @resource_id = @jobHash["resource_id"]

    if (@resource_id != '0')
      @resource = Resource.where("maxscheduler_id = ? and site_id = ? and board_id= ? and position = ?", @maxschedulerId, @siteId, @boardId, @resource_id)

      #binding.pry

      #@resource_id = @resource.first.id
      #Set the board for a job based on the assigned resource
      @resource = Resource.find(@resource_id)
      @board_id = @resource.board_id
      @job.board_id = @board_id.to_s
    end 

    @job.resource_id = @resource_id

    #Set parameters for building the row to time convert hash
    @operationhours = Operationhour.where("maxscheduler_id = ?", @maxschedulerId)
    @site = Site.find(@siteId)
    @rowHeight = @site.rowHeight.to_i
    @rowTimeIncrement = (@site.rowTimeIncrement).to_f
    @pixelValue = @job.schedPixelVal
    @numOfWeeks = ((current_user.numberOfWeeks).to_i) - 1
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
            @currenttime = @currentDay + (entry.start.to_f * 3600)      
              
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

    @job.schedDateTime = @jobTime
    @job.save(:validate => false)

    @jobChange = ''
    @jobBefore = ''
    @jobAfter = ''
    @job.attributes.each do |attr_name, attr_value|
      if !(attr_name == 'created_at' || attr_name == 'updated_at' || attr_name == 'id') 
        if (attr_value != (@jobOld[attr_name.to_s]))
          @jobBefore = @jobBefore + ' | ' + attr_name.to_s + ' : ' + @jobOld[attr_name.to_s].to_s
          @jobAfter =  @jobAfter + ' | ' + attr_name.to_s  + ' : ' + attr_value.to_s
        end
      end    
    end

    #Job update should succeed at this point. Lets make an entry to the job log
    @joblog1 = JobLogging.new
    @joblog1.update_attributes(:job_id => @job.id, :user_id => current_user.id, :maxscheduler_id => @maxschedulerId, :jobDetailsBefore => @jobBefore, :jobDetailsAfter => @jobAfter, :jobDetailsChange => 'Delta')

    #binding.pry
  end
    
  # asyncNew used by MXWebUI to create new jobs which are unscheduled and end up in List View
  def asyncNew
    @job = Job.new(params[:job])

    @job.maxscheduler_id = @maxschedulerId
    @job.site_id = @siteId
    @job.resource_id = 0
    @job.user_id = current_user.id

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

  def moveDownForm
    #This is a method to support a form that was on the schedule page. A job id and value will be passed in. 
    #The purpose is to move this job to an later start time as well as all jobs underneath it. 
    @job = Job.find(params[:jobId])
    @moveAmountInTime = params[:shiftAmountInTime]
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
    @numOfWeeks = ((current_user.numberOfWeeks).to_i) + 3
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
          @currenttime = @currentDay + (entry.start.to_f * 3600)      
            
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
                               @moveAmountInPixels = (@moveAmountInTime.to_f / @rowTimeIncrement) * @rowHeight
                               @newPixelValue = @pixelValue.to_i + @moveAmountInPixels
            end #end hash
            #Have the new pixel value. Now find the new time for that pixel value
            @row = (@newPixelValue.to_i) / (@rowHeight.to_i)
            @timeOfRow = @dateHash[@row.to_s]
            #@secondsInRow = ((@pixelValue.to_i).fdiv(@rowHeight).abs.modulo(1)) * (@rowTimeIncrement * 3600)
            @secondsInRow = ((@newPixelValue.to_i).fdiv(@rowHeight).abs.modulo(1)) * (@rowTimeIncrement * 3600)
            @jobTime = (@timeOfRow.to_time) + (@secondsInRow.to_i)
            job.schedDateTime = @jobTime

            #binding.pry

            job.save(:validate => false)
    end #job loop         

     respond_to do |format|
       if @job.update_attributes(params[:job])
         format.html { redirect_to "/scheduler/mx"}
         format.json { head :no_content }
       else
         format.html { render action: "edit" }
         format.json { render json: @job.errors, status: :unprocessable_entity }
       end
     end
  end

  def moveDownDragDrop
    #This is a method to support group moving of jobs using the mouse and shift key. A job id and value will be passed in. 
    #The purpose is to move this job to an later start time as well as all jobs underneath it. 
    @job = Job.find(params[:jobId])
    @moveAmountInPixels = params[:shiftAmountInPixels]
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
    @numOfWeeks = ((current_user.numberOfWeeks).to_i) + 3
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
          @currenttime = @currentDay + (entry.start.to_f * 3600)      
            
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
                               @newPixelValue = @pixelValue.to_i + @moveAmountInPixels.to_i
            end #end hash
            #Have the new pixel value. Now find the new time for that pixel value
            @row = (@newPixelValue.to_i) / (@rowHeight.to_i)
            @timeOfRow = @dateHash[@row.to_s]
            #@secondsInRow = ((@pixelValue.to_i).fdiv(@rowHeight).abs.modulo(1)) * (@rowTimeIncrement * 3600)
            @secondsInRow = ((@newPixelValue.to_i).fdiv(@rowHeight).abs.modulo(1)) * (@rowTimeIncrement * 3600)
            @jobTime = (@timeOfRow.to_time) + (@secondsInRow.to_i)
            job.schedDateTime = @jobTime

            #binding.pry

            job.save(:validate => false)
    end #job loop         

     respond_to do |format|
       if @job.update_attributes(params[:job])
         format.html { redirect_to "/scheduler/mx"}
         format.json { head :no_content }
       else
         format.html { render action: "edit" }
         format.json { render json: @job.errors, status: :unprocessable_entity }
       end
     end
  end


  #AsynchDelete used for deleting jobs from the MX UI
  def asyncDelete
    @job = Job.find(params[:id])
    @job.destroy

    respond_to do |format|
      format.html { redirect_to jobs_url }
      format.json { head :no_content }
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
