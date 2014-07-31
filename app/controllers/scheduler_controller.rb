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
      @jobData = ''
      
      @operationhours = Operationhour.where("maxscheduler_id = ?", @maxschedulerId)
      @dateTimeAry = "var date_array = ["
      @site = Site.find(@siteId)
      @numOfWeeks = ((current_user.numberOfWeeks).to_i) - 1
      @rowTimeIncrement = (@site.rowTimeIncrement).to_f

      @schedStartDate = current_user.schedStartDate.to_time
      @schedStartDateTime = @schedStartDate + (@operationhours[0].start.to_f * 3600)
      #@schedStartDateTime = @schedStartDateTime.getlocal(current_user.timeZone)
      @currentDay = @schedStartDate
      @numberOfRows = 0
      @rowCounter = 0
      @dateHash = Hash.new

      #Hacky bad code needed to make up for resource labeling problem in UI
      #For all the resources on this board create a lookup for their position value
      @resources = Resource.where("board_id = ?", @boardId)

      #Create date/time column array
      #Repeat the weekly Operation Hours config for a number of weeks, first loop
      for j in 0..@numOfWeeks 
        @weekStartDate = @schedStartDate + (j.to_i * 7 * 24 * 3600)

            #Create Date/Time stamps for each Operation Hours entry, which defines a continous length of time for a day
            @operationhours.each do | entry |
              @currentDay = @weekStartDate + ((entry.dayOfTheWeek.to_i) * 24 *3600)
              @currenttime = @currentDay + (entry.start.to_f * 3600)      
              
              #Loop through the number of rows for that Operation Hours entry
              for i in 1..(entry.numberOfRows.to_i)
                  @dateTimeAry = @dateTimeAry + (@currenttime.strftime("%m/%d/%y %I:%M%p")) + '",'
                  @dateHash[@rowCounter] = @currenttime
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
          @operationalHoursRowCount = @operationalHoursRowCount + entry.numberOfRows.to_i 
      end  

      #Repeat the weekly Operation Hours config for a number of weeks, first loop
      for j in -1..(@numOfWeeks + 1) 
        @weekStartDate = @schedStartDate + (j.to_i * 7 * 24 * 3600)

            #Create Date/Time stamps for each Operation Hours entry, which defines a continous length of time for a day
            @operationhours.each do | entry |
              @currentDay = @weekStartDate + ((entry.dayOfTheWeek.to_i) * 24 *3600)
              @currenttime = @currentDay + (entry.start.to_f * 3600)      
              
              #Loop through the number of rows for that Operation Hours entry
              for i in 1..(entry.numberOfRows.to_i)
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

  #Method will be called frequently through Ajax with client time stamp data. Comparison will be done between client and server time stamp. 
  #If the timestamps match there is no update needed. If client time stamp is behind, jobData refresh needed.
  def checkForJobDataUpdate
    require 'date'

    #Need to grab the clientSide time stamp posted through ajax
    clientTimeStamp = params[:clientTimeStamp]
    boardId = params[:boardId]
    @board = Board.find(boardId)
    serverTimeStamp = @board.scheduleTimeStamp.to_time
    zone = ActiveSupport::TimeZone.new("Eastern Time (US & Canada)")

    serverTimeStamp = serverTimeStamp.in_time_zone(zone)

    clientTimeStamp = Time.parse(clientTimeStamp)
    clientTimeStamp = clientTimeStamp.in_time_zone(zone)

    timeStatus = ''

    if (serverTimeStamp == clientTimeStamp)
      timeStatus = "Match"
    end
    if (serverTimeStamp > clientTimeStamp)
      timeStatus = "Update"
    end
    if (serverTimeStamp < clientTimeStamp)
      timeStatus = "Messed"
    end

    #binding.pry

    render :text => "'"+timeStatus+"'", :status => 200

  end


  #Method for returning job data to rails. Screaming to be refactored and done properly.
  def jobData

      #render :layout => false

      #Pick up the data that connects with the right maxscheduler, site, board. 
      #Careful that unscheduled jobs don't have board set yet

      @attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)
      @operationhours = Operationhour.where("maxscheduler_id = ? and site_id = ?", @maxschedulerId, @siteId)

      @sites = Site.where("maxscheduler_id = ?", @maxschedulerId)
      @boards = Board.where("maxscheduler_id = ? and site_id = ?", @maxschedulerId, @siteId)

      @resources = Resource.where("maxscheduler_id = ? and site_id = ?", @maxschedulerId, @siteId)
      
      #Get the list of jobs that should be displayed on this schedule, ie. in the schedule time frame
      @site = Site.find(@siteId)
      board = Board.find(@boardId)

      #Figure out what jobs should be displayed on this schedule. The jobs contained within are the relevant ones. 
      #There are the class of jobs that should not be moved: span the schedule, start before and overlap, start on and extend
      #Need to find the jobs that don't move. For this to work, need to have the start and end times. End times can change
      #thus need to calculate dynamically.

      #Figure out some timebound parameters for figuring out scheduled job edge cases
      @schedEndTime = @schedStartDateTime + (3600 * 24 * 7 * 5)
      @schedUpperBound = @schedStartDateTime - (3600 * 24 * 7 )
      @schedLowerBound = @schedEndTime + (3600 * 24 * 7 )
      #@schedStartTime = @schedStartTime.getlocal(current_user.timeZone)

      @scheduledJobs = Job.where("maxscheduler_id = ? and board_id = ? and schedDateTime >= ? and schedDateTime <= ? and resource_id != '0' ", @maxschedulerId, @boardId, @schedUpperBound, @schedLowerBound)
      @listJobs = Job.where("maxscheduler_id = ? and site_id = ? and resource_id = '0' ", @maxschedulerId, @siteId)
      @jobs = @scheduledJobs|@listJobs

      #binding.pry
      
      @numOfResources = Resource.where("board_id= ?", @boardId).count
      @colWidth = 1000/@numOfResources

      @rowHeight = (@site.rowHeight).to_f
      @rowTimeIncrement = (@site.rowTimeIncrement).to_f

      #Figure out if one of the Attributes holds job length. If not use Default length set in the Site table
      @attributes.each do |attr|
          if (attr.name == "Duration")
              #attrPosition = attr.importposition
              attrPosition = attr.listposition
              @jobLengthInData = "attr" + attrPosition.to_s
          end
      end

      #Figure out if one of the Attributes holds a job Color. If not use Default length set in the Site table
      @attributes.each do |attr|
          if (attr.name == "Color")
              #attrPosition = attr.importposition
              attrPosition = attr.listposition
              @jobColorPosition = "attr" + attrPosition.to_s
          end
      end

      #Create array that holds job data
      @jobAry = "jobBucket = {" + "\n"
      @jobs.each do |job|

          if (@jobLengthInData)
              @jobDurationInTime = (job[@jobLengthInData].to_f) * 3600 
              @jobDisplaySize = (( @jobDurationInTime.to_f) / (@rowTimeIncrement * 3600) ) * @rowHeight 
          else              
              @jobDurationInTime = @site.defaultJobLength.to_i * 3600
              @jobDisplaySize = (( @jobDurationInTime.to_f) / (@rowTimeIncrement * 3600) ) * @rowHeight 
          end
        
          #Figure out if the job is in the Listview or scheduled
          if (job.resource_id == "0")
              @joblane = "0"
              @pixelValue = 0
          else
              @jobStartTime = job.schedDateTime
              @jobStartTime = @jobStartTime.to_time
              @jobEndTime = @jobStartTime + @jobDurationInTime

                #Calculate the position on the schedule from the job time stamp
                #Step through the dateHash to find out which row the job should be placed in. Check the job time is bounded by the row
                @pixelValue = 0

                #Hacky bad code to make up for the incorrect labeling of resources in the UI. Backend uses resource id, UI uses 
                #resource position
                #@joblane = job.resource_id

                @joblane = job.resource_id

                #Search through extendedHash and find out which row a job sits in. Would prefer this to be function instead of a looping search              
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
                @draggable = 'yes'
                #binding.pry

                @rowStatusEnd = @rowDataEnd[1]

                #if (@pixelValue > (@operationalHoursRowCount * @rowHeight))
                @pixelValue = @pixelValue - (@operationalHoursRowCount * @rowHeight)
                @pixelValueEndOfJob = @pixelValueEndOfJob - (@operationalHoursRowCount * @rowHeight)

                #if the job is entirely before the schedule start, don't do anything. 'next' jumps out of the loop
                if (@rowStatusStart == -1 && @rowStatusEnd == -1)
                    #I should do more than just jump out of loop, these jobs should not go into jobData 
                    next
                end
                #if the job starts before the schedule start and overlaps onto the visible schedule
                if (@rowStatusStart == -1 && @rowStatusEnd == 0)
                    @jobDisplaySize = @pixelValue.abs
                    @pixelValue = 0 
                    @draggable = 'no'
                end

                #Should clearly handle if (@rowStatusStart == 1 && @rowStatusEnd == 1)

                #if the job starts on the visible schedule, but trails off the end
                if (@rowStatusStart == 0 && @rowStatusEnd == 1)
                    @pixelValue = @pixelValue
                    @jobDisplaySize = (@operationalHoursRowCount * @rowHeight) - @pixelValue
                    @draggable = 'no'
                end
                #if the job is entirely after the schedule end, don't do anything. 'next' jumps out of the loop
                if (@rowStatusStart == 1 && @rowStatusEnd == 1)
                    #I should do more than just jump out of loop, these jobs should not go into jobData 
                    next
                end

          end 

          #Building the JavaScript string to hold job data
          @jobAry = @jobAry + job.id.to_s + ': (new jobCreate( ' + job.id.to_s + ',' + @joblane.to_s + ',"100",' + 
                              @pixelValue.to_s + ',' + @colWidth.to_s + ',' + @jobDisplaySize.to_s + 
                              ',"' + job[@jobColorPosition].to_s + '","' + @draggable.to_s + '",'

          @i = 1
          #Push out the attribute values          
          @attributes.each do |attr|
              if attr.name
                  @x = "attr"+ @i.to_s
                  #Need to protect against Null attribute values in database
                  if (job[@x].nil?) 
                      job[@x] =' '
                  end    
                  @jobAry = @jobAry + '"' + job[@x] + '",'
              end #if end
              @i = @i + 1
          end #attribute end 

          #Appending to the job string to close it out properly to Abide by JavaScript rules ;)
          @jobAry = @jobAry + '"The Dude Abides")),'
      
      end #job end
      
      @jobAry = @jobAry + '};'

      #Push out to job log that an update has been pushed out. Gives a sense of synch traffic. 
      @joblog1 = JobLogging.new
      @joblog1.update_attributes(:job_id => ' ', :user_id => current_user.id, :maxscheduler_id => @maxschedulerId, :jobDetailsBefore => 'Job Data call', :jobDetailsAfter => ' ', :jobDetailsChange => ' ')


      @jobAry = @jobAry + "\n\n" + 'clientScheduleTimeStamp = "' + board.scheduleTimeStamp.to_s + '";'
      #@jobAry = @jobAry + "\n\n" + 'ClientScheduleTimeStamp = "' + DateTime.now.utc.to_s + '"'

      render :js =>  @jobAry
  end 

#Method to drive the static scheduling portion of the scheduling UI. 
def mx

      #Array for color coding the roles
      colorArray = Array.new 
      colorArray[0] = 'FFFF00' #light green
      colorArray[1] = '0066CC' #aqua
      colorArray[2] = 'FF6666' #pink
      colorArray[3] = '00FF00' #light yellow
      colorArray[4] = 'FF00FF' #magenta
      colorArray[5] = 'FFCC00' #orange
      colorArray[6] = '00FFFF' #blue

      #Build a JavaScript array to hold attribute labels
      @attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId).order('listposition asc')
      @attrString = "attributeNamesAry = new Array ("
      @attributes.each do |attr|
          @attrString = @attrString + '"' + attr.name + '",'
      end
      @attrString = @attrString + '"Empty");'

      @dateTimeColumnWidth = @site.dateTimeColumnWidth
      @schedulerRowHeight = @site.rowHeight
      @schedItemDelimiter = @site.schedItemDelimiter
      @insideWidth = current_user.DeskSchedWidth     #Hack: added 20 px to line up ListView width to Schedule width
      @outsideWidth = (current_user.DeskSchedWidth.to_i + 20).to_s     #Hack: added 20 px to line up ListView width to Schedule width
      @scheduleHeight = current_user.SchedHeight
      @scheduleListHeight = current_user.SchedListHeight
      @userLevel = current_user.userLevel

      #Need the current site and board name
      @currentSiteName = Site.find(@siteId).name
      @currentBoardName = Board.find(@boardId).name

      #Get Sites and Boards data to drive the schedule board menu
      @sites = Site.where("maxscheduler_id = ?", @maxschedulerId)
      @boards = Board.where("maxscheduler_id = ? and site_id = ?", @maxschedulerId, @siteId)

      #Build the top row of the schedule with the resource labels
      @resources = Resource.where("maxscheduler_id = ? and site_id = ? and board_id = ?", @maxschedulerId, @siteId, @boardId)

      #Figure out the resource column widths
      @resourceColWidth = (@insideWidth.to_f - @dateTimeColumnWidth.to_f) / @resources.size.to_f

      @resourceString = ""
      @resources.order("position").each do |resource|
          @resourceString = @resourceString + '<td bgcolor="#FF6600" align=center width=' + @resourceColWidth.to_s + '><b>' + resource.name + '</b></td>'
      end    

      #Figure out if one of the Attributes holds job length. If not use Default length set in the Site table
      @attributes.each do |attr|
          if (attr.name == "Duration")
              #attrPosition = attr.importposition
              attrPosition = attr.listposition
              @jobLengthInData = "attr" + attrPosition.to_s
          end
      end

      #Figure out if one of the Attributes holds a job Color. If not use Default length set in the Site table
      @attributes.each do |attr|
          if (attr.name == "Color")
              #attrPosition = attr.importposition
              attrPosition = attr.listposition
              @jobColorPosition = "attr" + attrPosition.to_s
          end
      end

      #Build resource dicitonary that is used by JavaScript to find out which resource a job has landed in. 
      #Improvement: Add support for having the resources out of order, nsot currently supported. 
      @resourceDictString = '{';
      @resCounter = 1;
      @resources.order("position").each do |resource|
          @resourceDictString = @resourceDictString + (resource.id).to_s + ':' + ((@resCounter - 1)*@resourceColWidth.to_f + @dateTimeColumnWidth.to_f + 5).to_s + ','
          @resCounter = @resCounter + 1;
      end 
      @resourceDictString = @resourceDictString + '};'

      #Build the scheduling table
      @schedulingTable = ""
      @rowCounter = 0

      for j in 0..@numOfWeeks 
        @weekStartDate = @schedStartDate + (j.to_i * 7 * 24 * 3600)

            #Create Date/Time stamps for each Operation Hours entry, which defines a continous length of time for a day
            @operationhours.each do | entry |
              @currentDay = @weekStartDate + ((entry.dayOfTheWeek.to_i) * 24 *3600)
              @currenttime = @currentDay + (entry.start.to_f * 3600)      
              
              #Loop through the number of rows for that Operation Hours entry
              for i in 1..(entry.numberOfRows.to_i)
                  @schedulingTable = @schedulingTable + "<tr>\n"
                      @schedulingTable = @schedulingTable + "<td valign=top align=center width=" + @dateTimeColumnWidth + " height=" + @schedulerRowHeight +  
                              " style=background-color:" + colorArray[entry.dayOfTheWeek.to_i] +";>" + @dateHash[@rowCounter].strftime("%a-%b-%d %I:%M%p")  + " </td>" 
                      #Put in a table cell <td> for each resource for this board
                      for k in 1 .. (@resources.size)                     
                          @schedulingTable = @schedulingTable + "<td width=" + @resourceColWidth.to_s + "></td>\n"
                      end   
                      @schedulingTable = @schedulingTable + "</tr>\n"
                  @rowCounter = @rowCounter + 1
              end      
            end
      end

      #Get the attribute names and create some javascript that is used by Datatables
      @attributeString = '{ "sTitle": "Id","sWidth": "60px" },'
      @attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)
      @attributes.order("listposition")

      for r in 0..((@attributes.size) - 1) 
          @attributeString = @attributeString + '{ "sTitle": "' + @attributes[r].name + '","sWidth": "' + (@attributes[r].columnWidth).to_s + 'px" },'     
      end

      #Next build the modal forms for New job. Key is to put in the given attribute names
      @newJobForm = '<table>'
      for v in 1..((@attributes.size)) 
          if (@attributes[(v - 1)].name == 'Color')
            @newJobForm = @newJobForm + '<tr><td width=80px>&emsp;' + @attributes[(v - 1)].name + ': &emsp; </td><td><select name=attr' + v.to_s + 
                                    ' id=attr' + v.to_s + '>
                                      <option value="white" style="background-color: white" >White</option>
                                      <option value="yellow" style="background-color: yellow" >Yellow</option>
                                      <option value="cyan" style="background-color: cyan" >Cyan</option>
                                      <option value="lightseagreen" style="background-color: lightseagreen" >Teal</option>
                                      <option value="orange" style="background-color: orange" >Orange</option>
                                      <option value="magenta" style="background-color: magenta" >Magenta</option>
                                      <option value="lime" style="background-color: lime" >Lime</option>
                                      <option value="red" style="background-color: red" >Red</option>
                                      <option value="purple" style="background-color: purple" >Purple</option>
                                      <option value="brown" style="background-color: brown" >Brown</option>
                                      <option value="green" style="background-color: green" >Green</option>
                                      <option value="blue" style="background-color: blue" >Blue</option>
                                      </select>
                                     </td></tr>'     
          else
            @newJobForm = @newJobForm + '<tr><td width=80px>&emsp;' + @attributes[(v - 1)].name + ': &emsp; </td><td><input type=text name=attr' + v.to_s + 
                                    ' id=attr' + v.to_s + ' value="" size=40></td></tr>'     
          end
      end
      @newJobForm = @newJobForm + '</table>'

      #Next build the modal forms for Edit job. Key is to put in the given attribute names
      @editJobForm = '<table>JobId: <span id=displayJobId></span><input type="hidden" name="eid" id="eid" class="text ui-widget-content ui-corner-all" />'
      for w in 1..((@attributes.size)) 
          if (@attributes[(w - 1)].name == 'Color')
            @editJobForm = @editJobForm + '<tr><td width=80px>&emsp;' + @attributes[(w - 1)].name + ': &emsp; </td><td><select name=eattr' + w.to_s + 
                                    ' id=eattr' + w.to_s + '>
                                      <option value="white" style="background-color: white" >White</option>
                                      <option value="yellow" style="background-color: yellow" >Yellow</option>
                                      <option value="cyan" style="background-color: cyan" >Cyan</option>
                                      <option value="lightseagreen" style="background-color: lightseagreen" >Teal</option>
                                      <option value="orange" style="background-color: orange" >Orange</option>
                                      <option value="magenta" style="background-color: magenta" >Magenta</option>
                                      <option value="lime" style="background-color: lime" >Lime</option>
                                      <option value="red" style="background-color: red" >Red</option>
                                      <option value="purple" style="background-color: purple" >Purple</option>
                                      <option value="brown" style="background-color: brown" >Brown</option>
                                      <option value="green" style="background-color: green" >Green</option>
                                      <option value="blue" style="background-color: blue" >Blue</option>
                                      </select>
                                     </td></tr>'     
          else
          @editJobForm = @editJobForm + '<tr><td width=80px>&emsp;' + @attributes[(w - 1)].name + ': &emsp; </td><td><input type=text name=eattr' + w.to_s + 
                                    ' id=eattr' + w.to_s + ' value="" size=40></td></tr>'     
          end                          
      end
      @editJobForm = @editJobForm +'</table>'
      
      #For the scheduling screen, screen real estate is at a premium, like New York city! Thus don't want to apply layout template application.html.erb
      render :layout => false

  end 

end