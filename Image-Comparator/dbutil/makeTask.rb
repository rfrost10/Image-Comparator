require 'net/http'
require 'uri'
require 'json'
require 'securerandom'
uuid = SecureRandom.uuid


# get the number of documents as a command line arg
ARGV.each { |arg| puts "Argument: #{arg}" }
user = ARGV[0]
i_list = ARGV[1]
task_type=ARGV[2]
task_order=ARGV[3] #.to_int
dbname = ARGV[4]
DNS = ARGV[5]
userpass = ARGV[6]

if (ARGV.size <3) then
    puts "Usage: ruby : #{$PROGRAM_NAME} <user> <image-list name> <image-list-type> <task-order> <dbname> <DNS> <user:password>"
    puts "Where:\n"
    puts "1 <user> is the user assigned to the task.\n"
    puts "2 <image-list name> is an Image Compare List created before this step.\n"
    puts "3 <image-list-type> is compare, OCTcompare, classify, classify_nine or quandrant.\n"
    puts "4 <task-order> is the order in which to complete this task relatve to other tasks.\n"
    puts "5 <dbname> is the name of the db made in previous steps.\n"
    puts "6 <DNS> is the VM or ip-address of the machine you are using.\n"
    puts "7 <user:password> VM or local credentials.\n"
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

if (task_type=="compare") then
  obj["image_compare_list"]=i_list
elsif (task_type=="OCTcompare") then
  obj["OCTimage_compare_list"]=i_list
else
  puts "refer to help"
  exit
end




# need to change icl in db to reflect



#puts obj.inspect
#puts obj.to_json


# put the results in the database
docname = uuid

url = "http://#{userpass}@#{DNS}"+":5984/" + dbname + "/" + docname
puts url

uri = URI.parse(url)

http = Net::HTTP.new(uri.host, uri.port)
request = Net::HTTP::Put.new(uri.path)

resp = http.request(request, obj.to_json)
puts resp.body
