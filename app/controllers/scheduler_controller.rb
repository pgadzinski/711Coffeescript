class SchedulerController < ApplicationController
  #include Sdata
  before_filter :getscheduleparameters

  def getscheduleparameters
      #binding.pry
      @maxschedulerId = current_user.maxscheduler_id
      @siteId = current_user.currentSite
      @boardId = current_user.currentBoard
      
      #Create date/time column array
      @dateTimeAry = "var date_array = ["
      @site = Site.find(@siteId)
      @numOfRows = (@site.numberOfRows).to_i
      @rowTimeIncrement = (@site.rowTimeIncrement).to_i

      #Protect if schedStartDate and timeZone is null ---- Doesn't work yet
      if ( (current_user.schedStartDate) && (current_user.timeZone) )
          @time = Time.parse(current_user.schedStartDate).getutc
          @time = @time.getlocal(current_user.timeZone)
      else
          @time = Time.now
      end

      @time = @time-@time.sec-@time.min%59*60
      
      for i in 0..@numOfRows
        @dateTimeAry = @dateTimeAry + '"' + (@time.strftime("%m/%d/%Y %I:%M%p")) + '",'
        @time = @time + (@rowTimeIncrement * 3600)
      end
      
      @dateTimeAry = @dateTimeAry + "];"
  
  end  

  def showData

      #Pick up the data that connects with the right maxscheduler, site, board. 
      #Careful that unscheduled jobs don't have board set yet

      @attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)
      @operationhours = Operationhour.where("maxscheduler_id = ? and site_id = ?", @maxschedulerId, @siteId)

      @sites = Site.where("maxscheduler_id = ?", @maxschedulerId)
      @boards = Board.where("maxscheduler_id = ? and site_id = ?", @maxschedulerId, @siteId)

      @resources = Resource.where("maxscheduler_id = ? and site_id = ?", @maxschedulerId, @siteId)
      
      @jobs = Job.where("maxscheduler_id = ? and site_id = ?", @maxschedulerId, @siteId)

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

      #Create array that holds job data
      @jobAry = "var MXS_job_data = {"
      @jobs.each do |job|
        #Figure out if the job is in the Listview or scheduled
        if (job.resource_id == "none")
            @joblane = "0"
            @jobLocation = "listview"
        else
            @joblane = job.resource_id
            @jobLocation = "board"
            #@boardName = Board.find(Resource.find(job.resource_id).board_id).name
        end 
        @jobAry = @jobAry + '"' + job.id.to_s 
        @jobAry = @jobAry + 
        '":[ {"left":0, "top":' + job.schedPixelVal.to_s + ', "width":' + @colWidth.to_s + ' , "height":100, 
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

  end

end
