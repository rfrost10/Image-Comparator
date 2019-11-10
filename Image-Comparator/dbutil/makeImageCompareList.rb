require 'net/http'
require 'uri'
require 'json'

# Include config variables - BB 
require './Configuration' 
include Configuration 
 
DNS = Configuration::DNS 
DB_PORT = Configuration::DB_PORT 
DB_ADMIN_USER = Configuration::DB_ADMIN_USER 
DB_ADMIN_PASS = Configuration::DB_ADMIN_PASS 
IMAGES_DB = Configuration::IMAGES_DB 

#  # Include config variables - BB


if (ARGV.size != 4) then
    puts "Usage: ruby : #{$PROGRAM_NAME} <doc range> <pct repeat> <image type> <list name>";
    puts "1. <doc range> is a ruby style range in quotations, e.g., \"10..20\" \n";
    puts "2. <pct repeat> is the percentage of repeated pairs to be displayed\n";
    puts "3. <image type> is 'ret' for retinal scan or 'oct' for OCT scan\n"
    puts "4. <list name> is a new Image Compare List name.\n"
    exit
end


# get the number of documents as a command line arg
#ARGV.each { |arg| puts "Argument: #{arg}" }
rangeStr = ARGV[0]
pctRep = ARGV[1]
image_type = ARGV[2]
list_name = ARGV[3]

if (image_type == "oct") then
    image_type = "OCTimage_compare_list"
elsif (image_type == "ret") then
    image_type = "image_compare_list"
else
    puts "Invalid image type."
    exit
end

#puts rangeStr
#puts rangeStr.class
rangeBnds = rangeStr.split("..").map{|d| Integer(d)}
#puts rangeBnds[0]
#puts rangeBnds[1]

range = Range.new(rangeBnds[0], rangeBnds[1]);
rangeArray= range.to_a
sizeDocs=rangeArray.size


# create pairs
pairs = []
for i in (0..sizeDocs-1) do
    for j in (i+1..sizeDocs-1) do
        #pairs.push([i, j])
        pairs.push([rangeArray[i], rangeArray[j]])
    end
end
#puts pairs.inspect
#puts pairs.size

# shuffle them
pairs.shuffle!
#puts pairs.inspect
#puts pairs.size



# add 20% duplicates by finding a random entry and inserting it randomly
dupCt = pairs.size*(pctRep.to_f/100) +1
puts "dup count is #{dupCt}."
for i in (1..dupCt) do
    idx = rand(pairs.size) # who to repeat
    #puts "repeating #{idx}"
    pair = pairs[idx].dup # duplicate the array
    pair.reverse! # if the repeat shows up next to the original, this will be good
    #puts "pair is " + pair.inspect
    idx = rand(pairs.size) # where to put the repeat
    #puts "pair is going to #{idx}"
    pairs.insert(idx, pair)
end
puts pairs.inspect
puts pairs.size

obj = { type:image_type,
        count:pairs.size,
        list:pairs,
        timeAdded:Time.now()}
puts obj.inspect
puts obj.to_json



# put the results in the database
url = "http://#{DB_ADMIN_USER}:#{DB_ADMIN_PASS}@#{DNS}:#{DB_PORT}/" + IMAGES_DB + "/" + list_name 


uri = URI.parse(url)

http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Put.new(uri.path)

resp = http.request(request, obj.to_json)
puts resp.body
