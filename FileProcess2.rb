require 'csv'    

csv_text = File.read('./Donut.csv')
csv = CSV.parse(csv_text, :headers => false)

csv.each do |rowAry|
	rowAry.each { |entry|
		puts entry.to_s
	}
end


