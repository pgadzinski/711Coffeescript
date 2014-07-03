class ImportdataController < ApplicationController
  
  before_filter :getscheduleparameters

  def getscheduleparameters
      @maxschedulerId = current_user.maxscheduler_id
      @siteId = current_user.currentSite
      @boardId = current_user.currentBoard
  end  
  
  # GET /importdata
  # GET /importdata.json
  def index
    @importdata = Importdatum.where("maxscheduler_id = ?", @maxschedulerId).order('id desc')

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @importdata }
    end
  end

  # GET /importdata/1
  # GET /importdata/1.json
  def show
    @importdatum = Importdatum.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @importdatum }
    end
  end

  # GET /importdata/1/review
  # At the review stage, cleaning out single and double quotes. They destroy the JavaScript front end. 
  # Will need to find bake in support for quotes that doesn't effect the JavaScript frontend. 
  def review
    @importdatum = Importdatum.find(params[:id])

    importData = @importdatum.data

    importData = importData.gsub("\'", "")
    importData = importData.gsub("\"", "")

    @importdatum.data = importData

  end

  # GET /importdata/1/reviewDesktopScheduledJobs
  # Review the data assuming your bringing it over from the MaxScheduler desktop. Remove the id column from MaxScheduler export
  # Also clean out single and double quotes which ruin JavaScript. These are scheduled jobs
  def reviewDesktopScheduledJobs
    @importdatum = Importdatum.find(params[:id])

    importData = @importdatum.data
    importData = importData.gsub("\'", "")
    importData = importData.gsub("\"", "")

    #Take out the first column that holds MaxScheduler desktop id data, which is useless. 
    require 'csv'    
    csv = CSV.parse(importData, {:headers => false, :col_sep => "," } )
    @cleanedImportData = ''

    #Play with trying to reorder the data according to attribute config in MaxScheduler
    headingRowAry = csv[0]
    numOfAttributes = headingRowAry.length - 1 - 4  #don't count id and 4 trailing columns of schedule data
    @attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)

    #Loop through the attributes to figure out the data mapping
    @columnMapAry = Array.new
    @attrIndex = 0
    @attributes.each do |attr|
      @attrName = attr.name
      @columnMapAry[@attrIndex] = headingRowAry.index(@attrName)
      @attrIndex = @attrIndex + 1       
    end
    scheduleDataArray = [ (@attrIndex + 1), (@attrIndex + 2), (@attrIndex + 3), (@attrIndex + 4)]
    @columnMapAry = @columnMapAry.concat(scheduleDataArray)


    # @columnMapAry = [5,1,2,3,4]

    csv.each do | rowAry |  
      rowAry.shift          #gets rid of first element of an array in this case the id we don't want.  
      #Now apply the columnMapAry to re-arrange the data to fall under the right columns
      @columnMapAry.each do | colMapIndex |
        colMapIndex = colMapIndex.to_i - 1
        entry = rowAry[colMapIndex]
        @cleanedImportData = @cleanedImportData + entry.to_s + ","
      end
      @cleanedImportData = @cleanedImportData + "\r\n"
    end

    #binding.pry

    #Save change to database
    @importdatum.data = @cleanedImportData
    @importdatum.save

  end

# GET /importdata/1/reviewDesktopListViewJobs
  # Review the data assuming your bringing it over from the MaxScheduler desktop. Remove the id column from MaxScheduler export
  # Also clean out single and double quotes which ruin JavaScript. These are listview jobs. 
  def reviewDesktopListViewJobs
    @importdatum = Importdatum.find(params[:id])

    importData = @importdatum.data
    importData = importData.gsub("\'", "")
    importData = importData.gsub("\"", "")

    #Take out the first column that holds MaxScheduler desktop id data, which is useless. 
    require 'csv'    
    csv = CSV.parse(importData, {:headers => false, :col_sep => "," } )
    @cleanedImportData = ''

    #Play with trying to reorder the data according to attribute config in MaxScheduler
    headingRowAry = csv[0]
    numOfAttributes = headingRowAry.length - 1 - 4  #don't count id and 4 trailing columns of schedule data
    @attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)

    #Loop through the attributes to figure out the data mapping
    @columnMapAry = Array.new
    @attrIndex = 0
    @attributes.each do |attr|
      @attrName = attr.name
      @columnMapAry[@attrIndex] = headingRowAry.index(@attrName)
      @attrIndex = @attrIndex + 1       
    end
    #scheduleDataArray = [ (@attrIndex + 1), (@attrIndex + 2), (@attrIndex + 3), (@attrIndex + 4)]
    #@columnMapAry = @columnMapAry.concat(scheduleDataArray)


    # @columnMapAry = [5,1,2,3,4]

    csv.each do | rowAry |  
      rowAry.shift          #gets rid of first element of an array in this case the id we don't want.  
      #Now apply the columnMapAry to re-arrange the data to fall under the right columns
      @columnMapAry.each do | colMapIndex |
        colMapIndex = colMapIndex.to_i - 1
        entry = rowAry[colMapIndex]
        @cleanedImportData = @cleanedImportData + entry.to_s + ","
      end
      @cleanedImportData = @cleanedImportData + "\r\n"
    end

    #binding.pry

    #Save change to database
    @importdatum.data = @cleanedImportData
    @importdatum.save

  end

  # GET /importdata/1/edit
  # Method for importing jobs to the ListView
  def createjobs
    @importdata = Importdatum.where("maxscheduler_id = ?", @maxschedulerId)
    @importdatum = Importdatum.find(params[:id])
    attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)

    #Adding the feature to only import unique jobs. This works off of the unique field definition in Sites. Use the unique key, do comparison 
    #between existing jobs and jobs to import. Reject jobs that are dubplicates. Try to show these to user
    @jobImportCount = 0
    @jobRejectCount = 0
    @jobRejectString = ''
    
    @existingJobs = Job.where("maxscheduler_id = ?", @maxschedulerId)
    @existingJobHash = Hash.new

    #Build a Hash that is used to grab just the request data columns from the import file. There is ImportPosition which defines which columns should be imported. 
    @attrToImportAry = Array.new 
    attributes.each do | attr |
      @attrToImportAry.push(attr.importposition)
    end

    @site = Site.find(@siteId)
    if (@site.uniqueDataFields != "(NULL)")
      @uniqueFieldsAry = @site.uniqueDataFields.split(",")
    end

    #Build a hash of existing jobs, just storing the unique id
    if (@site.uniqueDataFields != "(NULL)")
        @existingJobs.each do | existingJob |
              uniqueJobKeyExisting = ''
              @uniqueFieldsAry.each do | attrEntry | 
                  uniqueJobKeyExisting = uniqueJobKeyExisting + existingJob[attrEntry]
              end  
              @existingJobHash[existingJob.id] = uniqueJobKeyExisting
        end  
    end

    #Pull in import data and parse out to a form
    require 'csv'    
    csv = CSV.parse(@importdatum.data, {:headers => false, :col_sep => "," } )
    @rowCounter = 1

    #Step through each job in the csv and try to save it. 
    csv.each do | rowAry |    
      colCounter = 1
      @job = Job.new(params[:job])
      @job.maxscheduler_id = @maxschedulerId
      @job.site_id = @siteId
      @job.board_id = @boardId
      @job.user_id = current_user.id
      @job.resource_id = "0"
      @job.schedPixelVal = "0"

      #Loop imports only columns that have an attribute Importposition value
      @attrToImportAry.each do |importPosition|
              @x = "attr" + colCounter.to_s
              @job[@x] = rowAry[importPosition - 1]
              colCounter = colCounter + 1
      end  

      if (@site.uniqueDataFields != "(NULL)")
    
          #For the specific job pick out the unique key
          uniqueJobKeyNew = ''
          @uniqueFieldsAry.each do | attrEntry | 
                 uniqueJobKeyNew = uniqueJobKeyNew + @job[attrEntry]
          end 

          #Test if the new job is already in MX
          if !(@existingJobHash.has_value?(uniqueJobKeyNew))
              @job.save
              @jobImportCount = @jobImportCount + 1
          else
              @jobRejectCount = @jobRejectCount + 1
              @jobRejectString = @jobRejectString + uniqueJobKeyNew + ','
          end
      else
         @job.save
      end  

      #binding.pry

      @rowCounter = @rowCounter + 1
    end

    if (@site.uniqueDataFields != "(NULL)")
    
      importMessage = 'MaxScheduler imported: ' + @jobImportCount.to_s + ' Jobs, Rejected: ' + @jobRejectCount.to_s + ' Rejected Keys: ' + @jobRejectString
    else
      importMessage = 'No unique key is defined in the configuration. Number of jobs imported is ' + @rowCounter.to_s
    end

    respond_to do |format|
      format.html { redirect_to @importdatum, notice: importMessage }
      format.json { render json: @importdata }
    end

  end  

  # GET /importdata/1/edit
  # Method for importing data from MaxScheduler desktop into MaxScheduler Web
  # Will always assume there is a proper, matching configurations
  def importScheduledJobs
    @importdata = Importdatum.where("maxscheduler_id = ?", @maxschedulerId)
    @importdatum = Importdatum.find(params[:id])
    attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)

    #Pull in import data and parse out to a form
    require 'csv'    
    csv = CSV.parse(@importdatum.data, {:headers => false, :col_sep => "," } )
    csv.shift       #get rid of first row of data because this is header data 
    @rowCounter = 1
    csv.each do | rowAry |    
      #binding.pry
      colCounter = 1    #Going to re-use the MaxScheduler id for matching data purposes
      @job = Job.new(params[:job])
      @job.maxscheduler_id = @maxschedulerId
      @job.site_id = @siteId
      @job.board_id = @boardId
      @job.user_id = current_user.id
      @job.schedPixelVal = "0"

      attributes.each do |attr|
          if attr.name
              @x = "attr" + colCounter.to_s
              @job[@x] = rowAry[colCounter - 1]    #Take into account arrays indexed at 0
              colCounter = colCounter + 1
          end 
      end  

      #There are still three more columns: BoardId, ResourceId and ScheduleDateTime. 
      colCounter = colCounter - 1

      #Need to do a reference look up to get the board_id and resource_id 
      @board_label = rowAry[colCounter]
      @boardResult = Board.where("maxscheduler_id = ? and name = ?", @maxschedulerId.to_s, @board_label.to_s)
      @job.board_id = @boardResult[0].id
      colCounter = colCounter + 1
  
      @resource_label = rowAry[colCounter]
      @resourceResult = Resource.where("maxscheduler_id = ? and name = ?", @maxschedulerId, @resource_label)
      @job.resource_id = @resourceResult[0].id
      colCounter = colCounter + 1

      #The export from MaxScheduler has a bad date format, 1/8/13 , need to parse and re-arrange
      @importDate = rowAry[colCounter]
      colCounter = colCounter + 1
      @importTime = rowAry[colCounter]
      @importString = @importDate + " " + @importTime
      @importDateTime = DateTime.strptime(@importString, '%m/%d/%y %H:%M')
    
      @job.schedDateTime = @importDateTime

      @job.save
      @rowCounter = @rowCounter + 1
    end

    respond_to do |format|
      format.html { redirect_to @importdatum, notice: 'MaxScheduler imported scheduled jobs successfully.' }
      format.json { render json: @importdata }
    end

  end  


  # GET /importdata/new
  # GET /importdata/new.json
  def new
    @importdatum = Importdatum.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @importdatum }
    end
  end

  # GET /importdata/1/edit
  def edit
    @importdatum = Importdatum.find(params[:id])

  end

  # POST /importdata
  # POST /importdata.json
  def create
    @importdatum = Importdatum.new(params[:importdatum])

    respond_to do |format|
      if @importdatum.save
        format.html { redirect_to @importdatum, notice: 'Importdatum was successfully created.' }
        format.json { render json: @importdatum, status: :created, location: @importdatum }
      else
        format.html { render action: "new" }
        format.json { render json: @importdatum.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /importdata/1
  # PUT /importdata/1.json
  def update
    @importdatum = Importdatum.find(params[:id])
    
    respond_to do |format|
      if @importdatum.update_attributes(params[:importdatum])
        format.html { redirect_to @importdatum, notice: 'Importdatum was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @importdatum.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /importdata/1
  # DELETE /importdata/1.json
  def destroy
    @importdatum = Importdatum.find(params[:id])
    @importdatum.destroy

    respond_to do |format|
      format.html { redirect_to importdata_url }
      format.json { head :no_content }
    end
  end
end
