class MaxschedulersController < ApplicationController
  # GET /maxschedulers
  # GET /maxschedulers.json
  #include Sdata
  
  before_filter :getscheduleparameters

  def getscheduleparameters
      @maxschedulerId = current_user.maxscheduler_id
      @siteId = current_user.currentSite
      @boardId = current_user.currentBoard
      @configurationScreen = true
  end  

  
  def set
      session[:maxscheduler] = params[:id]
      redirect_to '/scheduler/showData'
  end
  
  def index
    @maxschedulers = Maxscheduler.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @maxschedulers }
    end
  end

  # GET /maxschedulers/1
  # GET /maxschedulers/1.json
  def show
    @maxscheduler = Maxscheduler.find(params[:id])
    session[:maxscheduler] = @maxscheduler
            
    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @maxscheduler }
    end
  end

  # GET /maxschedulers/new
  # GET /maxschedulers/new.json
  def new
    @maxscheduler = Maxscheduler.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @maxscheduler }
    end
  end

  # GET /maxschedulers/1/edit
  def edit
    @maxscheduler = Maxscheduler.find(params[:id])
  end

  #Here we're going to populate default application data for new customers. 
  def populateData
    @maxscheduler = Maxscheduler.find(params[:id])
    session[:maxscheduler] = @maxscheduler
    currentTime = Time.now.to_s       

    #Fill in code to populate data,  
    @site = Site.new
    @site.update_attributes(:name => "Factory77", :rowTimeIncrement=> "1", :dateTimeColumnWidth => "120", :created_at => currentTime, :updated_at => currentTime, :maxscheduler_id => @maxschedulerId, :rowHeight => "50", :defaultJobLength =>"2", :schedItemDelimiter => "<br>", :uniqueDataFields => "(NULL)")

    @board = Board.new
    @board.update_attributes(:name => "Building1", :maxscheduler_id => @maxschedulerId, :site_id => @site.id)
    
    #Create Resources
    @resource1 = Resource.new
    @resource1.update_attributes(:name => "Machine1", :maxscheduler_id => @maxschedulerId, :site_id => @site.id, :board_id => @board.id, :position => 1)
    @resource2 = Resource.new
    @resource2.update_attributes(:name => "Machine2", :maxscheduler_id => @maxschedulerId, :site_id => @site.id, :board_id => @board.id, :position => 2)
    @resource3 = Resource.new
    @resource3.update_attributes(:name => "Machine3", :maxscheduler_id => @maxschedulerId, :site_id => @site.id, :board_id => @board.id, :position => 3)
    @resource4 = Resource.new
    @resource4.update_attributes(:name => "Machine4", :maxscheduler_id => @maxschedulerId, :site_id => @site.id, :board_id => @board.id, :position => 4)
    @resource5 = Resource.new
    @resource5.update_attributes(:name => "Machine5", :maxscheduler_id => @maxschedulerId, :site_id => @site.id, :board_id => @board.id, :position => 5)

    #Create default attributes
    @attribute1 = Attribute.new
    @attribute1.update_attributes(:name => "JobNum", :maxscheduler_id => @maxschedulerId, :importposition => 1, :listposition => 1, :scheduleposition => 1, :columnWidth => 50)
    @attribute2 = Attribute.new
    @attribute2.update_attributes(:name => "Cust", :maxscheduler_id => @maxschedulerId, :importposition => 2, :listposition => 2, :scheduleposition => 2, :columnWidth => 50)
    @attribute3 = Attribute.new
    @attribute3.update_attributes(:name => "PONum", :maxscheduler_id => @maxschedulerId, :importposition => 3, :listposition => 3, :scheduleposition => 3, :columnWidth => 50)
    @attribute4 = Attribute.new
    @attribute4.update_attributes(:name => "Duration", :maxscheduler_id => @maxschedulerId, :importposition => 4, :listposition => 4, :scheduleposition => 4, :columnWidth => 50)
    @attribute5 = Attribute.new
    @attribute5.update_attributes(:name => "Color", :maxscheduler_id => @maxschedulerId, :importposition => 5, :listposition => 5, :scheduleposition => 5, :columnWidth => 50)

    #Create default operation hours
    @operationhour0 = Operationhour.new
    @operationhour0.update_attributes(:dayOfTheWeek => 0, :start => 8, :numberOfRows => 8, :maxscheduler_id => @maxschedulerId, :site_id => @site.id)
    @operationhour1 = Operationhour.new
    @operationhour1.update_attributes(:dayOfTheWeek => 1, :start => 8, :numberOfRows => 8, :maxscheduler_id => @maxschedulerId, :site_id => @site.id)
    @operationhour2 = Operationhour.new
    @operationhour2.update_attributes(:dayOfTheWeek => 2, :start => 8, :numberOfRows => 8, :maxscheduler_id => @maxschedulerId, :site_id => @site.id)
    @operationhour3 = Operationhour.new
    @operationhour3.update_attributes(:dayOfTheWeek => 3, :start => 8, :numberOfRows => 8, :maxscheduler_id => @maxschedulerId, :site_id => @site.id)
    @operationhour4 = Operationhour.new
    @operationhour4.update_attributes(:dayOfTheWeek => 4, :start => 8, :numberOfRows => 8, :maxscheduler_id => @maxschedulerId, :site_id => @site.id)


    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @maxscheduler }
    end
  end

  # POST /maxschedulers
  # POST /maxschedulers.json
  def create
    @maxscheduler = Maxscheduler.new(params[:maxscheduler])

    respond_to do |format|
      if @maxscheduler.save
        format.html { redirect_to @maxscheduler, notice: 'Maxscheduler was successfully created.' }
        format.json { render json: @maxscheduler, status: :created, location: @maxscheduler }
      else
        format.html { render action: "new" }
        format.json { render json: @maxscheduler.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /maxschedulers/1
  # PUT /maxschedulers/1.json
  def update
    @maxscheduler = Maxscheduler.find(params[:id])

    respond_to do |format|
      if @maxscheduler.update_attributes(params[:maxscheduler])
        format.html { redirect_to @maxscheduler, notice: 'Maxscheduler was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @maxscheduler.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /maxschedulers/1
  # DELETE /maxschedulers/1.json
  def destroy
    @maxscheduler = Maxscheduler.find(params[:id])
    @maxscheduler.destroy

    respond_to do |format|
      format.html { redirect_to maxschedulers_url }
      format.json { head :no_content }
    end
  end
  
   private
    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end
  
end
