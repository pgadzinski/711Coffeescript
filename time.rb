require 'time'

#Build the date/time array
	  @opHrsHash = Hash.new
	  @dateTimeAry = "var date_array = ["
      @numOfRows = "60".to_i
      @rowHeight = "30"
      @rowTimeIncrement = "2".to_i
      @time = Time.parse("2012-09-29")
      @pixelValue = 0

      for i in 0..@numOfRows
        @dateTimeAry = @dateTimeAry + '"' + (@time.strftime("%m/%d/%y %I:%M%p")) + '",'
        @time = @time + (@rowTimeIncrement * 3600)
        @opHrsHash[@pixelValue] = [i,@time.to_i]
        @pixelValue = @pixelValue.to_i + (@rowTimeIncrement.to_i * @rowHeight.to_i)
      end
      
      @dateTimeAry = @dateTimeAry + "];"
      puts @opHrsHash
      #puts @dateTimeAry

@rowHeight = "30".to_f
@rowTimeIncrement = ("2").to_f

#@time = Time.parse('2012-09-29')
@time = ("2012-09-29 00:55:12.000000").to_time
@timeTop = @time.getlocal("-00:00")           # time for the top of the schedule

#@jobTime = Time.parse("2012-09-30 00:55:12.000000")
@jobTime = ("2012-09-30 00:55:12.000000").to_time
@timeDifference = @jobTime - @timeTop

puts @timeDifference

@pixelValue = ((@timeDifference.to_f) / (@rowTimeIncrement * 3600) ) * (@rowHeight)

puts (@rowTimeIncrement * 3600)

puts @pixelValue