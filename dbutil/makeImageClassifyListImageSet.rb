require 'net/http'
require 'uri'
require 'json'


if (ARGV.size != 3) then
    puts "Usage: ruby : #{$PROGRAM_NAME} <imageSet> <list name> <pct repeat>\n";
    puts "1 - <imageSet> is an existing imageSet in the database\n";
    puts "2 - <list name> is the new classify list's name\n";
    puts "3 - <pct repeat> is the percentage of repeated pairs to be displayed\n";
    puts "full example: ruby #{$PROGRAM_NAME} imageSet test_classify_list 10";
    exit
end



# get the number of documents as a command line arg
#ARGV.each { |arg| puts "Argument: #{arg}" }
imgSetName = ARGV[0]
nameStr = ARGV[1]
pctRep =ARGV[2]

viewUrl = "http://localhost:5984/ret_images/_design/basic_views/_view/imageSet2ImageId?key=\"#{imgSetName}\""
puts viewUrl
encoded_url = URI.encode(viewUrl)
uri = URI.parse(encoded_url)
#puts uri
#http = Net::HTTP.new(uri.host, uri.port)
#request = Net::HTTP::Get.new(uri.path+uri.qu)

#uri=URI(viewUrl)
resp= Net::HTTP.get(uri)
response = JSON.parse(resp)

#puts response


imageIdRows = response['rows']
imageIds = []
imageIdRows.each {|x| imageIds.push(x['value'].to_i) }
imageIds.sort!
puts imageIds

rangeBnds = [imageIds.first, imageIds.last]
puts "rangeBnds is #{rangeBnds}"

range = Range.new(rangeBnds[0], rangeBnds[1]);
rangeArray= range.to_a
sizeDocs=rangeArray.size

puts "sizeDocs is #{sizeDocs}"


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
dbname = "ret_images/"
docname = nameStr
url = 'http://localhost:5984/' + dbname + docname
puts url

uri = URI.parse(url)

http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Put.new(uri.path)

puts "here"
resp = http.request(request, obj.to_json)
puts resp.body
