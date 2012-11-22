class ImportdataController < ApplicationController
  #include Sdata
  
  before_filter :getscheduleparameters

  def getscheduleparameters
      @maxschedulerId = current_user.maxscheduler_id
      @siteId = current_user.currentSite
      @boardId = current_user.currentBoard
  end  
  
  # GET /importdata
  # GET /importdata.json
  def index
    @importdata = Importdatum.where("maxscheduler_id = ?", @maxschedulerId)

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

  # GET /importdata/1/edit
  def review
    @importdatum = Importdatum.find(params[:id])

  end

  # GET /importdata/1/edit
  def createjobs
    @importdata = Importdatum.where("maxscheduler_id = ?", @maxschedulerId)
    @importdatum = Importdatum.find(params[:id])
    attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)

    #Pull in import data and parse out to a form
    require 'csv'    
    csv = CSV.parse(@importdatum.data, {:headers => false, :col_sep => "," } )
    @rowCounter = 1
    csv.each do | rowAry |    
      colCounter = 1
      @job = Job.new(params[:job])
      @job.maxscheduler_id = @maxschedulerId
      @job.site_id = @siteId
      @job.user_id = current_user.id
      @job.resource_id = "none"
      @job.schedPixelVal = "0"

      attributes.each do |attr|
          if attr.name
              @x = "attr" + colCounter.to_s
              @job[@x] = rowAry[colCounter - 1]
              colCounter = colCounter + 1
              binding.pry
          end 
      end  

      @job.save
      @rowCounter = @rowCounter + 1
    end

    respond_to do |format|
      format.html # index.html.erb
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
