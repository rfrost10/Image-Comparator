require 'net/http'
require 'uri'
require 'json'



if (ARGV.size != 4) then
    puts "Usage: ruby : #{$PROGRAM_NAME} <image set name> <pct repeat> <list name> <dbname>";
    puts "Where: \n"
    puts "1 <image set name> was the name given to addImagesToDb_jkc.rb for the <imageSetName>.\n";
    puts "2 <pct repeat> is the percentage of repeated pairs to be displayed.\n"
    puts "3 <list name> is a new Image Compare List name.\n";
    puts "4 <dbname> name of db created under Instructions for use.\n"
    exit
end


# get the number of documents as a command line arg
#ARGV.each { |arg| puts "Argument: #{arg}" }
imgSetName = ARGV[0]
pctRep =ARGV[1]
nameStr = ARGV[2]
dbname = ARGV[3]

# find range from searching db for images that have image_set_name
viewUrl = "http://localhost:5984/#{dbname}/_design/basic_views/_view/imageSet2ImageId?key=\"#{imgSetName}\""
puts viewUrl
encoded_url = URI.encode(viewUrl)
uri = URI.parse(encoded_url)

#uri=URI(viewUrl)
resp= Net::HTTP.get(uri)

# grab the ids, sort and confirm all from lowest to highest are in the list
#response = JSON.parse(resp.body)
response = JSON.parse(resp)

#puts response
imageIdRows = response['rows']
imageIds = []
imageIdRows.each {|x| imageIds.push(x['value'].to_i) }
imageIds = imageIds.sort()
puts imageIds

rangeBnds = [imageIds.first, imageIds.last]
puts "rangeBnds is #{rangeBnds}"

range = Range.new(rangeBnds[0], rangeBnds[1]);
rangeArray= range.to_a
sizeDocs=rangeArray.size

puts "sizeDocs is #{sizeDocs}"

# create pairs
pairs = []
for i in (0..sizeDocs-1) do
    for j in (i+1..sizeDocs-1) do
        #pairs.push([i, j])
        pairs.push([rangeArray[i], rangeArray[j]])
    end
end

# shuffle them
pairs.shuffle!

puts pairs
puts "pairs.size is #{pairs.size}"

# add 20% duplicates by finding a random entry and inserting it randomly
dupCt = pairs.size*(pctRep.to_f/100) +1
puts "dup count is #{dupCt}."
for i in (1..dupCt) do
    idx = rand(pairs.size) # who to repeat
    pair = pairs[idx].dup # duplicate the array
    pair.reverse! # if the repeat shows up next to the original, this will be good
    idx = rand(pairs.size) # where to put the repeat
    pairs.insert(idx, pair)
end
puts pairs.inspect
puts pairs.size


obj = { type:"image_compare_list",
        count:pairs.size,
        list:pairs,
        timeAdded:Time.now()}
puts obj.inspect
puts obj.to_json



# put the results in the database
url = 'http://localhost:5984/' + dbname + "/" +nameStr 

uri = URI.parse(url)

http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Put.new(uri.path)

resp = http.request(request, obj.to_json)
puts resp.body
