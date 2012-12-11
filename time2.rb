require 'time'

#Build the date/time array
    @opHrsHash = Hash.new
    @opHrsHash[1] = [1,'8:00', '10']
    @opHrsHash[2] = [2,'6:00', '8']
    @opHrsHash[3] = [3,'10:00', '12']
    @opHrsHash[4] = [2,'6:00', '8']
    @opHrsHash[5] = [3,'10:00', '12']

    @dateTimeAry = "var date_array = ["
    @numOfRows = "60".to_i
    @rowHeight = "30"
    @rowTimeIncrement = "1".to_i
    @time = Time.parse("2012-09-29")
    @pixelValue = 0

    @opHrsHash.each do | entry, ary |
      puts ary[2].to_i
      @time = Time.parse("2012-09-29 " + ary[2])
      @time.localtime("-00:00") 
      
      for i in 0..ary[2].to_i
          @dateTimeAry = @dateTimeAry + '"' + (@time.strftime("%m/%d/%y %I:%M%p")) + '",'
          @time = @time + (@rowTimeIncrement * 3600)
          puts @time
      end



    end

    
    @dateTimeAry = @dateTimeAry + "];"
    #puts @dateTimeAry
