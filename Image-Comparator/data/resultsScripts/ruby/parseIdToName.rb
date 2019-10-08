require 'csv'
require 'json'
=begin
csv_string = CSV.generate do |csv|
  JSON.parse(File.open("/Users/jkc/Documents/retinalImaging/website/Image-Comparator/data/id_to_name.json").read).each do |hash|
    csv << hash.values
  end
end

puts csv_string
=end


json=JSON.parse(File.open("/Users/jkc/Documents/retinalImaging/website/Image-Comparator/data/id_to_name.json").read)
rows= json['rows']

rows.each do |l|
#  puts l.class
end

CSV.open("idName.csv", "w") do |csv|
rows.each do |hash| #open json to parse
    csv << hash.values #write value to file
  end
end
