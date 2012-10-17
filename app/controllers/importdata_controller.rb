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
    @importdata = Importdatum.all

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
    
    binding.pry
    
    @requestHash = params["importdatum"]

    #Re-assemble the data for the import file to support editing the parsed out data
    @numberOfImportedRows = @requestHash["numberOfImportedRows"]
    @attributes = Attribute.where("maxscheduler_id = ?", @maxschedulerId)
    @numberOfAttributes = @attributes.size

    @rebuiltImportString = ""

    for @row in 1..(@numberOfImportedRows.to_i)
      for @col in 1..(@numberOfAttributes.to_i)
        @position = @row.to_s + @col.to_s
        @rebuiltImportString = @rebuiltImportString + @requestHash[@position] + ","
        @requestHash.delete(@position) 
      end
      @rebuiltImportString = @rebuiltImportString + "\n"  
    end

    @requestHash.delete("numberOfImportedRows")
    @mergedHash = @requestHash.merge("data" => @rebuiltImportString)

    params["importdatum"] = @mergedHash

    binding.pry

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
