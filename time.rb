require 'time'

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