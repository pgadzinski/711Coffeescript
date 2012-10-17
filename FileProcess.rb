require 'csv'    

csv_text = File.read('./Donut.csv')
csv = CSV.parse(csv_text, :headers => true)

#puts (csv.to_s)

a = Hash.new
b = ""

firstRow = csv.first

firstHash = firstRow.to_hash

keys = firstHash.keys

puts (keys.to_s)

csv.each do |row|
  @row = row.to_hash

  @row.each do |key, value| # Or:  hash.each do |key, value|
  puts "#{key} is #{value}"
  end

  #row.keys do | keyValue |
  #	puts keyValue.to_s
  #	#@tableString = @tableString + "<td>" + keyValue.to_s + "</td>"
  #end

  a = row
  #puts a["Product-Name"]	  
  row = row.to_s
  b = row 
end

#puts a["Product-Name"]