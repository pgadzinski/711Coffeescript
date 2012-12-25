class SchedulerController < ApplicationController
  #include Sdata
  require 'time'
  before_filter :getscheduleparameters

  def getscheduleparameters
      #binding.pry
      @maxschedulerId = current_user.maxscheduler_id
      @siteId = current_user.currentSite
      @boardId = current_user.currentBoard
      @user = current_user
      
      @operationhours = Operationhour.where("maxscheduler_id = ?", @maxschedulerId)
      @dateTimeAry = "var date_array = ["
      @site = Site.find(@siteId)
      @numOfWeeks = ((@site.numberOfWeeks).to_i) - 1
      @rowTimeIncrement = (@site.rowTimeIncrement).to_i

      @schedStartDate = current_user.schedStartDate.to_time
      @schedStartDateTime = @schedStartDate + (@operationhours[0].start.to_i * 3600)
      #@schedStartDateTime = @schedStartDateTime.getlocal(current_user.timeZone)
      @currentDay = @schedStartDate
      @numberOfRows = 0
      @rowCounter = 0
      @dateHash = Hash.new

      #Create date/time column array
      #Repeat the weekly Operation Hours config for a number of weeks, first loop
      for j in 0..@numOfWeeks 
        @weekStartDate = @schedStartDate + (j.to_i * 7 * 24 * 3600)

            #Create Date/Time stamps for each Operation Hours entry, which defines a continous length of time for a day
            @operationhours.each do | entry |
              @currentDay = @weekStartDate + ((entry.dayOfTheWeek.to_i) * 24 *3600)
              @currenttime = @currentDay + (entry.start.to_i * 3600)      
              
              #Loop through the number of rows for that Operation Hours entry
              for i in 1..(entry.end.to_i)
                  @dateTimeAry = @dateTimeAry + '"' + (@currenttime.strftime("%m/%d/%y %I:%M%p")) + '",'
                  @dateHash[@rowCounter.to_s] = @currenttime
                  @currenttime = @currenttime + (@rowTimeIncrement * 3600)
                  @rowCounter = @rowCounter + 1
              end      
            end
      end
      
      @numberOfRows = @rowCounter
      @dateTimeAry = @dateTimeAry + "];"
      @endOfSchedule = @currenttime


      #Create extended date/time hash which will be used to figure out which row a job belongs to as well as figure out job edge cases

      #Reset some defaults
      @currentDay = @schedStartDate
      @extendedNumberOfRows = 0
      @extendedRowCounter = 0
      @extendedDateHash = Hash.new

      #Figure out how many rows one week of operations hours is in row count
      @operationalHoursRowCount = 0
      @operationhours.each do | entry |
          @operationalHoursRowCount = @operationalHoursRowCount + entry.end.to_i 
      end  

      #Repeat the weekly Operation Hours config for a number of weeks, first loop
      for j in -1..(@numOfWeeks + 1) 
        @weekStartDate = @schedStartDate + (j.to_i * 7 * 24 * 3600)

            #Create Date/Time stamps for each Operation Hours entry, which defines a continous length of time for a day
            @operationhours.each do | entry |
              @currentDay = @weekStartDate + ((entry.dayOfTheWeek.to_i) * 24 *3600)
              @currenttime = @currentDay + (entry.start.to_i * 3600)      
              
              #Loop through the number of rows for that Operation Hours entry
              for i in 1..(entry.end.to_i)
                      #If a row is above the schedule startDateTime, then mark it 
                      if (j == -1)
                         @extendedDateHash[@extendedRowCounter.to_s] = [@currenttime,-1]
                      #If a row is below the schedule startDateTime, then mark it 
                      elsif (j == (@numOfWeeks + 1))
                         @extendedDateHash[@extendedRowCounter.to_s] = [@currenttime,1]
                      else
                      @extendedDateHash[@extendedRowCounter.to_s] = [@currenttime,0]
                      end
                  @currenttime = @currenttime + (@rowTimeIncrement * 3600)
                  @extendedRowCounter = @extendedRowCounter + 1
              end
            end
      end
      @extendedNumberOfRows = @extendedRowCounter
      
  end  


  def showData

      #Pick up the data that connects with the right maxscheduler, site, board. 
      #Careful that unscheduled jobs don't have board set yet

      @attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)
      @operationhours = Operationhour.where("maxscheduler_id = ? and site_id = ?", @maxschedulerId, @siteId)

      @sites = Site.where("maxscheduler_id = ?", @maxschedulerId)
      @boards = Board.where("maxscheduler_id = ? and site_id = ?", @maxschedulerId, @siteId)

      @resources = Resource.where("maxscheduler_id = ? and site_id = ?", @maxschedulerId, @siteId)
      
      #Get the list of jobs that should be displayed on this schedule, ie. in the schedule time frame
      #binding.pry
      @site = Site.find(@siteId)

      #Figure out what jobs should be displayed on this schedule. The jobs contained within are the relevant ones. 
      #There are the class of jobs that should not be moved: span the schedule, start before and overlap, start on and extend
      #Need to find the jobs that don't move. For this to work, need to have the start and end times. End times can change
      #thus need to calculate dynamically.

      #Figure out some timebound parameters for figuring out scheduled job edge cases
      @schedEndTime = @schedStartDateTime + (@numberOfRows * 3600 * @rowTimeIncrement)
      @schedUpperBound = @schedStartDateTime - (3600 * 24 * 7 )
      @schedLowerBound = @schedEndTime + (3600 * 24 * 7 )
      #@schedStartTime = @schedStartTime.getlocal(current_user.timeZone)

      @scheduledJobs = Job.where("maxscheduler_id = ? and site_id = ? and resource_id != 'none' and schedDateTime >= ? and schedDateTime <= ?", @maxschedulerId, @siteId, @schedUpperBound, @schedLowerBound)
      @listJobs = Job.where("maxscheduler_id = ? and site_id = ? and resource_id = 'none' ", @maxschedulerId, @siteId)
      @jobs = @scheduledJobs|@listJobs
      #@jobs = Job.where("maxscheduler_id = ? and site_id = ? ", @maxschedulerId, @siteId)

      #Create array that holds Board and Resource data
      @boardResourceAry = "var MXS_board_data = {"
      @boards.each do |board|
        @numOfResources = Resource.where("board_id= 2").count
        @colWidth = 1000/@numOfResources
        @boardResourceAry = @boardResourceAry + '"' + board.name.to_s + '":['
        @boardResourceAry = @boardResourceAry + '{"col_num":' + @numOfResources.to_s + ', "col_width": '+ @colWidth.to_s + '}, {'
            @resources.each do |resource|
                if (board.id.to_s == resource.board_id)
                    @boardResourceAry = @boardResourceAry + '"' + resource.id.to_s + '":"' + resource.name + '",' 
                end #if end
            end #resource end
        @boardResourceAry = @boardResourceAry  + ' } ],'
      end #board end
      @boardResourceAry = @boardResourceAry + '};'

      @rowHeight = (@site.rowHeight).to_f
      @rowTimeIncrement = (@site.rowTimeIncrement).to_f

      #Figure out if one of the Attributes holds job length. If not use Default length set in the Site table
      @attributes.each do |attr|
          if (attr.name == "Duration")
              attrPosition = attr.importposition
              @jobLengthInData = "attr" + attrPosition.to_s
          else
              @jobDurationInTime = @site.defaultJobLength.to_i * 3600
              @jobDisplaySize = (( @jobDurationInTime.to_f) / (@rowTimeIncrement * 3600) ) * @rowHeight 
          end
      end

      #Create array that holds job data
      @jobAry = "var MXS_job_data = {"
      @jobs.each do |job|
        
          #Figure out if the job is in the Listview or scheduled
          if (job.resource_id == "none")
              @joblane = "0"
              @jobLocation = "listview"
              @pixelValue = 0
              @jobDurationInTime = @site.defaultJobLength.to_i * 3600
              @jobDisplaySize = (( @jobDurationInTime.to_f) / (@rowTimeIncrement * 3600) ) * @rowHeight 
          else
              @jobStartTime = job.schedDateTime
              @jobStartTime = @jobStartTime.to_time
              @jobEndTime = @jobStartTime + @jobDurationInTime

              if (@jobLengthInData)
                @jobDurationInTime = (job[@jobLengthInData].to_i) * 3600 
              end              

                @jobDisplaySize = (( @jobDurationInTime.to_f) / (@rowTimeIncrement * 3600) ) * @rowHeight 

                #Calculate the position on the schedule from the job time stamp
                #Step through the dateHash to find out which row the job should be placed in. Check the job time is bounded by the row
                @pixelValue = 0
                @joblane = job.resource_id
                @jobLocation = "board"
                @jobRowNumber = 10000000
              
                @extendedDateHash.each do | rowNumber , rowDataStart |
                     @rowNumber = rowNumber
                     @rowStartDateTime = rowDataStart[0]
                     @rowEndDateTime = @rowStartDateTime + (@rowTimeIncrement * 3600)

                     if ((@rowStartDateTime <= @jobStartTime) && ( @jobStartTime <= @rowEndDateTime))
                          @jobRowNumber = @rowNumber           
                          @rowStatusStart = rowDataStart[1]
                          @pixelValue = (@jobRowNumber.to_i) * @rowHeight
                          @remainingTimeDifference = (@jobStartTime - @rowStartDateTime)
                          @pixelValue = @pixelValue + (((@remainingTimeDifference.to_f) / (@rowTimeIncrement * 3600) ) * @rowHeight )
                     end
                end

                #Find out which row the end of the job lands
                @pixelValueEndOfJob = @pixelValue + @jobDisplaySize
                @endRow = (@pixelValueEndOfJob) / (@rowHeight)
                @endRow = @endRow.to_i
                @rowDataEnd = @extendedDateHash[@endRow.to_s]

                #binding.pry

                @rowStatusEnd = @rowDataEnd[1]

                @pixelValue = @pixelValue - (@operationalHoursRowCount * @rowHeight)
                @pixelValueEndOfJob = @pixelValueEndOfJob - (@operationalHoursRowCount * @rowHeight)

                if (@rowStatusStart == -1 && @rowStatusEnd == 0)
                    @jobDisplaySize = @pixelValue
                    @pixelValue = 0 
                end
                if (@rowStatusStart == 0 && @rowStatusEnd == 1)
                    @pixelValue = @pixelValue
                    @jobDisplaySize = (@operationalHoursRowCount * @rowHeight) - @pixelValue
                end

          end 

          
          #If a job hasn't found a row to sit in, then it should be pushed to list view
          if @jobRowNumber == 10000000
              @jobLocation = "listview"
          end 

          @jobAry = @jobAry + '"' + job.id.to_s 
          @jobAry = @jobAry + 
          '":[ {"left":0, "top":' + @pixelValue.to_s + ', "width":' + @colWidth.to_s + ' , "height":' + @jobDisplaySize.to_s + ', 
          "location": "' + @jobLocation + '", "board": "Board1", "lane": ' + @joblane + '},{ '   
          @i = 1
          
          @attributes.each do |attr|
              if attr.name
                  @x = "attr"+ @i.to_s
                  @jobAry = @jobAry + '"' + attr.name + '":"' + job[@x] + '",'
              end #if end
              @i = @i + 1
          end #attribute end 

          @jobAry = @jobAry + '} , {"some_date":"data"} ],'
      
      end #job end
      
      @jobAry = @jobAry + '};'

      #Create a hash that defines how wide each column is
      @columnWidthsHash = "var MXS_field_widths = { 'id': 50, "
      @attributes.each do |attr|
              if attr.name
                  @columnWidthsHash = @columnWidthsHash + '"' + attr.name + '":"' + attr.columnWidth.to_s + '",'
              end #if end
      end #attribute end 
      @columnWidthsHash = @columnWidthsHash + "}"

  end

end
