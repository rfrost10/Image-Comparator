require 'net/http'
require 'uri'
require 'json'
require 'securerandom'
uuid = SecureRandom.uuid

# Include config variables - BB 
require './Configuration' 
include Configuration 
 
DNS = Configuration::DNS 
DB_PORT = Configuration::DB_PORT 
DB_ADMIN_USER = Configuration::DB_ADMIN_USER 
DB_ADMIN_PASS = Configuration::DB_ADMIN_PASS 
IMAGES_DB = Configuration::IMAGES_DB
ADMIN_PARTY = Configuration::ADMIN_PARTY


# Include config variables - BB


# get the number of documents as a command line arg
ARGV.each { |arg| puts "Argument: #{arg}" }
user = ARGV[0]
i_list = ARGV[1]
task_type=ARGV[2]
task_order=ARGV[3] #.to_int

description = "Default description that should be changed."
description=ARGV[4] if ARGV[4]

if (ARGV.size <3) then
  puts "Usage: ruby : #{$PROGRAM_NAME} <user> <image-list name> <image-list-type> <task-order> [<description>]"
  puts "Where:\n"
  puts "1 <user> is the user assigned to the task.\n"
  puts "2 <image-list name> is an Image Compare/Classify List created before this step.\n"
  puts "3 <image-list-type> is compare, OCTcompare, classify, classify_nine or quandrant.\n"
  puts "4 <task-order> is the order in which to complete this task relatve to other tasks.\n"
  puts "5 <description> Description that will be above images.\n"
  exit
end

#if task order is provided, use it otherwise task order is set to arbitrarily high number so that it shows up last
if (ARGV.size > 3)
  task_order=task_order.strip.to_i
  puts task_order
  puts task_order.class
else
  task_order=100
end


obj = { type:"task",
        task_type:task_type,
        task_order:task_order,
        user:user,
        timeAdded:Time.now(),
  #    image_compare_list:image_compare_list,
  #      image_classify_list:image_classify_list,
        current_idx:0,
        completed:false}


obj["list_name"]=i_list


# Delete if we don't need anymore
# if task_type=="compare"
#   obj["image_compare_list"]=i_list
# elsif task_type=="classify" || task_type=="classify_nine" || task_type=="quadrant"
#   obj["image_classify_list"]=i_list
# elsif task_type=="OCTcompare"
#   obj["OCTimage_compare_list"]=i_list
# else
#   puts "refer to help2"
#   exit
# end


# BB - not sure if this is important - #

# need to change icl in db to reflect
#puts obj.inspect
#puts obj.to_json

# BB - not sure if this is important - #


# put the results in the database
docname = uuid

url = "http://#{DNS}:#{DB_PORT}/" + IMAGES_DB + "/" + docname
puts url

####
uri = URI.parse(url)

http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Put.new(uri.request_uri)
if ADMIN_PARTY != true
  request.basic_auth(DB_ADMIN_USER, DB_ADMIN_PASS)
end
response = http.request(request, obj.to_json)
response = JSON.parse(response.body)
puts response
#####
