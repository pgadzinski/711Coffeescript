class OperationhoursController < ApplicationController

  require 'time'
  before_filter :getscheduleparameters

  def getscheduleparameters
      @maxschedulerId = current_user.maxscheduler_id
      @siteId = current_user.currentSite
      @boardId = current_user.currentBoard
      @configurationScreen = true
      @attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)
  end  

  # GET /operationhours
  # GET /operationhours.json
  def index
    @operationhours = Operationhour.where("maxscheduler_id = ?", @maxschedulerId)

    @rowHeight = 30
    @rowTimeIncrement = "4".to_i
    @numOfWeeks = "1".to_i - 1
    @schedStartDate = current_user.schedStartDate.to_time
    @currentDay = @schedStartDate
    @rowCounter = 0
    @dateHash = Hash.new

      @extendedNumberOfRows = 0
      @extendedRowCounter = 0
      @extendedDateHash = Hash.new

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

    @jobPosition = 0

    @row = @jobPosition/@rowHeight

    @secondsInRow = (@jobPosition.fdiv(@rowHeight).abs.modulo(1)) * (@rowTimeIncrement * 3600)

    @timeOfRow = @extendedDateHash[@row.to_s][0]

    #binding.pry

    @jobTime = (@timeOfRow.to_time) + (@secondsInRow.to_i)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @operationhours }
    end
  end

  # GET /operationhours/1
  # GET /operationhours/1.json
  def show
    @operationhour = Operationhour.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @operationhour }
    end
  end

  # GET /operationhours/new
  # GET /operationhours/new.json
  def new
    @operationhour = Operationhour.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @operationhour }
    end
  end

  # GET /operationhours/1/edit
  def edit
    @operationhour = Operationhour.find(params[:id])
  end

  # POST /operationhours
  # POST /operationhours.json
  def create
    @operationhour = Operationhour.new(params[:operationhour])

    respond_to do |format|
      if @operationhour.save
        format.html { redirect_to @operationhour, notice: 'Operationhour was successfully created.' }
        format.json { render json: @operationhour, status: :created, location: @operationhour }
      else
        format.html { render action: "new" }
        format.json { render json: @operationhour.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /operationhours/1
  # PUT /operationhours/1.json
  def update
    @operationhour = Operationhour.find(params[:id])

    respond_to do |format|
      if @operationhour.update_attributes(params[:operationhour])
        format.html { redirect_to @operationhour, notice: 'Operationhour was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @operationhour.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /operationhours/1
  # DELETE /operationhours/1.json
  def destroy
    @operationhour = Operationhour.find(params[:id])
    @operationhour.destroy

    respond_to do |format|
      format.html { redirect_to operationhours_url }
      format.json { head :no_content }
    end
  end
end
