require 'net/http'
require 'uri'
require 'json'



if (ARGV.size != 3) then
    puts "Usage: ruby : #{$PROGRAM_NAME} <doc range> <pct repeat> <list name>";
    puts "  where doc range is a ruby style range in quotations, e.g., \"10..20\" ";
    puts " and pct repeat is the percentage of repeated images to be displayed"
    puts "  full example: ruby #{$PROGRAM_NAME} \"10..20\" 20 bub";
    exit
end


# get the number of documents as a command line arg
#ARGV.each { |arg| puts "Argument: #{arg}" }
rangeStr = ARGV[0]
pctRep =ARGV[1]
nameStr = ARGV[2]


rangeBnds = rangeStr.split("..").map{|d| Integer(d)}

range = Range.new(rangeBnds[0], rangeBnds[1]);
rangeArray= range.to_a
sizeDocs=rangeArray.size

puts "rangeArray is #{rangeArray}"
# dupCt is calculated from pctRep (input)
dupCt = (rangeArray.size*(pctRep.to_f/100)).ceil

tmpArray=[]
tmpArray=rangeArray.sample(dupCt)

(rangeArray << tmpArray).flatten!

rangeArray.shuffle!


obj = { type:"image_classify_list",
        uniqueImageCount:sizeDocs,
        count:rangeArray.size,
        list:rangeArray,
        timeAdded:Time.now()}
#puts obj.inspect
#puts obj.to_json


# put the results in the database
dbname = "rop_images/"
docname = nameStr
url = 'http://localhost:5984/' + dbname + docname


uri = URI.parse(url)

http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Put.new(uri.path)

resp = http.request(request, obj.to_json)
puts resp.body
