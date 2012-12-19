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
      
      #Create date/time column array
      @operationhours = Operationhour.where("maxscheduler_id = ?", @maxschedulerId)
      @dateTimeAry = "var date_array = ["
      @site = Site.find(@siteId)
      @numOfWeeks = ((@site.numberOfRows).to_i) - 1
      @rowTimeIncrement = (@site.rowTimeIncrement).to_i

      @schedStartDate = current_user.schedStartDate.to_time
      #@schedStartDate = @schedStartDate.getlocal(current_user.timeZone)
      @currentDay = @schedStartDate
      @numberOfRows = 1
      @rowCounter = 0
      @dateHash = Hash.new

      #Repeat the weekly Operation Hours config for a number of weeks, first loop
      for j in 0..@numOfWeeks 
        @weekStartDate = @schedStartDate + (j.to_i * 7 * 24 * 3600)

            #Create Date/Time stamps for each Operation Hours entry, which defines a continous length of time for a day
            @operationhours.each do | entry |
              @currentDay = @weekStartDate + ((entry.dayOfTheWeek.to_i) * 24 *3600)
              @currenttime = @currentDay + (entry.start.to_i * 3600)      
              
              #Loop through the number of rows for that Operation Hours entry
              for i in 0..(entry.end.to_i)
                  @dateTimeAry = @dateTimeAry + '"' + (@currenttime.strftime("%m/%d/%y %I:%M%p")) + '",'
                  @dateHash[@rowCounter.to_s] = @currenttime
                  @currenttime = @currenttime + (@rowTimeIncrement * 3600)
                  @rowCounter = @rowCounter + 1
              end
            @numberOfRows = @numberOfRows + entry.end.to_i        
            end
      end
              
      @dateTimeAry = @dateTimeAry + "];"
      @endOfSchedule = @currenttime
  
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
      
      @scheduledJobs = Job.where("maxscheduler_id = ? and site_id = ? and resource_id != 'none' and schedDateTime >= ? and schedDateTime <= ?", @maxschedulerId, @siteId, @schedStartDate, @endOfSchedule)
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

      #Create array that holds job data
      @jobAry = "var MXS_job_data = {"
      @jobs.each do |job|
        
          #Figure out if the job is in the Listview or scheduled
          if (job.resource_id == "none")
              @joblane = "0"
              @jobLocation = "listview"
              @pixelValue = 0
          else
              @pixelValue = 0
              @joblane = job.resource_id
              @jobLocation = "board"
              @jobRowNumber = 10000000
                #Calculate the position on the schedule from the job time stamp
                #Step through the dateHash to find out which row the job should be placed in. Check the job time is bounded by the row
                @dateHash.each do | rowNumber , rowStartDateTime |
                     @jobTime = (job.schedDateTime).to_time
                     @rowNumber = rowNumber
                     @rowStartDateTime = rowStartDateTime
                     @rowEndDateTime = rowStartDateTime + (@rowTimeIncrement * 3600)

                     if ((rowStartDateTime < @jobTime) && ( @jobTime < @rowEndDateTime))
                          @jobRowNumber = rowNumber           
                          @pixelValue = (@jobRowNumber.to_i) * @rowHeight
                          @remainingTimeDifference = (@jobTime - rowStartDateTime)
                          @pixelValue = @pixelValue + (((@remainingTimeDifference.to_f) / (@rowTimeIncrement * 3600) ) * @rowHeight )
                     end
                end
          end 

          
          #If a job hasn't found a row to sit in, then it should be pushed to list view
          if @jobRowNumber == 10000000
              @jobLocation = "listview"
          end 

          @jobAry = @jobAry + '"' + job.id.to_s 
          @jobAry = @jobAry + 
          '":[ {"left":0, "top":' + @pixelValue.to_s + ', "width":' + @colWidth.to_s + ' , "height":100, 
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
