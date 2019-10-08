require 'json'
require 'time'
require 'csv'

#file = File.read('ret_images_1100_5_2_2015.json')
#file = File.read('ret_images_1100_5_2_2015.json')
#file = File.read('ret_images_laptop1.json')
#file = File.read('ret_images_4_27_2015.json')
#file = File.read('/Users/jkc/Documents/retinalImaging/website/data/ret_images_4_27_2015.json')
#file = File.read('/Users/jayashreekalpathy-cramer/Documents/rop/website/Image-Comparator/data/ret_images_4_27_2015.json')

#file = File.read('/Users/kalpathy/Documents/retinalImaging/website/ret_images_1330_17_8_2015.json')

#file = File.read('/Users/jkc/Documents/retinalImaging/website/data/ret_images_1330_17_8_2015.json')
#file = File.read('/Users/jkc/Documents/retinalImaging/website/data/ret_images_0900_09_30_2015.json')
#file = File.read('/Users/jkc/Documents/retinalImaging/website/data/ret_images_1220_12_06_2015.json')
file = File.read('/Users/jkc/Documents/retinalImaging/website/data/ret_images_2016_10_09_1515.json')

contents = JSON.parse(file)
#puts contents
iclDocs = contents['rows'].select{|x| x['doc']['type'] === "image_classify_list"}

#puts iclDocs

#iclResults = contents['rows'].select{|x| x['doc']['type'] === "imageClassifyResult" && x['doc']['user'] === "mike"}

#puts iclResults.size


# print the icl names
#iclDocs.each{|x| puts x['key']}



taskRows = contents['rows'].select{|x| x['doc']['type'] === "task" && x['doc']["task_type"]==="classify"}
tasks = []
taskRows.each{|x| tasks.push(x['doc'])}
#puts taskRows

# build task to icl map, to look up which icl each result belongs to
task2icl = Hash.new()
tasks.each{|x| task2icl[x['_id']] = x["image_classify_list"]}
puts task2icl


task2user = Hash.new()
tasks.each{|x| task2user[x['_id']] = x["user"]}
#puts task2user

#puts task2user.invert["susan"]
#puts task2user.find {|key,val| val=="susan"}

# now work on the results
#puts contents.class


icResultRows = contents['rows'].select{|x| x['doc']['type'] === "imageClassifyResult"}
#puts icResultRows.size
#icResultRows2 = icResultRows.select{|x| task2icl[x['doc']['task']] === "icl_1_10_rev1"}
#icResultRows2 = icResultRows.select{|x| task2icl[x['doc']['task']] === "icsfy_set34_rev2"}

#icResultRows2 = icResultRows.select{|x| task2icl[x['doc']['task']] === "icsfy_select25_rev1"}
#icResultRows2 = icResultRows.select{|x| task2icl[x['doc']['task']] === "icsfy_100"}
icResultRows2 = icResultRows.select{|x| task2icl[x['doc']['task']] === "secondSet100_classify"}



#icResultRows2 = icResultRows.select{|x| task2icl[x['doc']['task']] === "icl_9"}


#puts icResultRows2.size

icResults = []
icResultRows2.each{|x| icResults.push(x['doc'])}
#puts icResultRows2[0]

# sort by task_idx
icResults.sort_by!{|a| [a['user'], a['task_idx'], Time.parse(a['date'])]}
#puts icResults.size
#puts icResults


#icResults.sort!{|a,b| a['task_idx'] <=> b['task_idx']}
#puts icResults.size

#puts icResults
prevUser=''

prevTaskIdx=''
output = []


CSV.open("results_secondSet100-classify.csv", "w") do |csv|
#CSV.open("results_icsfy_100_rev.csv", "w") do |csv|
#  CSV.open("results_icsfy_select25_rev1.csv", "w") do |csv|

  csv << ['task_id', 'image',  'diagnosis', 'user', 'date', 'icl']
#CSV.open("results_100_rev1.csv", "w") do |csv|
icResults.each do |x|
  #puts "here"
  row = Hash.new()

  #row['task'] = x['task']
  row['task_idx'] = x['task_idx']
  row['image0'] = x['image0'] #.split('/').last
  row['diagnosis'] = x['diagnosis']
  row['user'] = x['user']
  row['date']=x['date']

  thisUser= x['user']
  thisTaskIdx=x['task_idx']
  thisTask=x['task']
  row['icl']=task2icl[thisTask]

  thisLine="#{x['task_idx']}, #{x['image0'].split('/').last}, #{x['diagnosis']}, #{x['user']}, #{x['date']}, #{row['icl']} \n"
  puts thisLine
  csv << [x['task_idx'], x['image0'].split('/').last,  x['diagnosis'], x['user'], x['date'], row['icl']]

=begin
  if(thisUser!=prevUser || thisTaskIdx!=prevTaskIdx)

      csv << [x['task_idx'], x['image0'].split('/').last, x['image1'].split('/').last, x['winner'], x['user'], x['date'], row['icl']]
      output.push(row)
    else
    #  puts thisUser
    #  puts thisTask

  end
  prevUser=thisUser
  prevTaskIdx=thisTaskIdx
=end

end
end

#puts output.size

#b = output.group_by { |h| h['task_idx'] }.values.select { |a| a.size > 1 }.flatten
#puts b.size

#puts output.class

#a=File.open('results1.txt','w')
#a << output
#a.close()
#=end
