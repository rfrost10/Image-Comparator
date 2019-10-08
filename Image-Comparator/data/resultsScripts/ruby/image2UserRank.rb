require 'json'
require 'time'
require 'csv'

def compareResults(a, b)

end


#file = File.read('ret_images_1100_5_2_2015.json')
file = File.read('ret_images_4_27_2015.json')

contents = JSON.parse(file)

iclDocs = contents['rows'].select{|x| x['doc']['type'] === "image_compare_list"}

# print the icl names
#iclDocs.each{|x| puts x['key']}

# find the tasks
taskRows = contents['rows'].select{|x| x['doc']['type'] === "task"}
tasks = []
taskRows.each{|x| tasks.push(x['doc'])}

# build task to icl map, to look up which icl each result belongs to
task2icl = Hash.new()
tasks.each{|x| task2icl[x['_id']] = x["image_compare_list"]}
#puts task2icl

task2user = Hash.new()
tasks.each{|x| task2user[x['_id']] = x["user"]}
#puts task2user

# now work on the results
icResultRows = contents['rows'].select{|x| x['doc']['type'] === "imageCompareResult"}
icResultRows2 = icResultRows.select{|x| task2icl[x['doc']['task']] === "icl_1_10_rev1"}
#icResultRows2 = icResultRows.select{|x| task2icl[x['doc']['task']] === "ICL_third_set_hundred_r2"}

icResults = []
icResultRows2.each{|x| icResults.push(x['doc'])}
#puts icResultRows2[0]

# sort by task_idx
icResults.sort_by!{|a| [a['user'], a['task_idx'], Time.parse(a['date'])]}

prevUser=''
prevTaskIdx=''
output = []

#remove duplicates
icResultsNoDups=[]
icResults.each do |x|  
    if (x['user'] != prevUser or x['task_idx'] != prevTaskIdx)
        icResultsNoDups.push(x);
    end
    
    prevUser=x['user']
    prevTaskIdx=x['task_idx']
end        
puts "icResult count: " + icResults.size.to_s
puts "icReultsNoDups count: " + icResultsNoDups.size.to_s

# now filter by user and then sort by normalized comparison
# todo, scan results for the usernames, for now, hard coded
users = ['mike', 'paul', 'susan', 'karyn', 'pete']
userToSortedImages = Hash.new();


users.each do |user| 
    # do an each loop to get all the users sorted lists
    userResults = icResultsNoDups.select { |x| x['user'] == user }
    puts user + " has " + userResults.size.to_s + " results"
    puts "the first is " + userResults[0].to_s


    # sort with compare function
    #generate numTimesWon and numTimesShown
    numTimesShown = Hash.new()

    userResults.each do |x|
        if (!numTimesShown[ x['image0'] ])
            numTimesShown[ x['image0'] ] = 0
        end
        if (!numTimesShown[ x['image1'] ])
            numTimesShown[ x['image1'] ] = 0
        end
        
        numTimesShown[ x['image0'] ] = numTimesShown[ x['image0'] ] +1
        numTimesShown[ x['image1'] ] = numTimesShown[ x['image1'] ] +1
    end

    numTimesWon = Hash.new()   
    userResults.each do |x|
        if (!numTimesWon[ x['image0'] ])
            numTimesWon[ x['image0'] ] = 0
        end
        if (!numTimesWon[ x['image1'] ])
            numTimesWon[ x['image1'] ] = 0
        end
        
        if (x['winner'] == "1")
            numTimesWon[ x['image0'] ] = numTimesWon[ x['image0'] ] +1
        end
        
        if (x['winner'] == "-1")
            numTimesWon[ x['image1'] ] = numTimesWon[ x['image1'] ] +1
        end
    end

    #puts numTimesWon.to_s
    images = numTimesShown.keys
    puts images.to_s
    images.sort!{|a,b|
        winRateA = numTimesWon[a]/numTimesShown[a]
        winRateB = numTimesWon[b]/numTimesShown[b]
        c = winRateA <=> winRateB 
        #ignoring ties for now!!
            # puts "c is " + c.to_s        
            # if c != 0 
                # puts "c is " + c.to_s
                # next
            # end
            # # handle ties
            # tieRes = userResults.select { |x| (x['image0'] == a and x['image1'] == b) or (x['image1'] == a and x['image0'] == b) }
            # puts tieRes.size.to_s
            # aWins = 0
            # bWins = 0
            # tieRes.each do |x| 
                # puts "here"
            # end

    }
#    puts images.to_s
    userToSortedImages[user] = images
end

#puts userToSortedImages



# spit out the results here
images = userToSortedImages['mike']

#CSV.open("image_to_user_list.csv", "w") do |csv|
  # csv << ['task_id', 'image0', 'image1', 'winner', 'user', 'date', 'icl']
# # CSV.open("results_100_rev1.csv", "w") do |csv|
  images.each do |x|

      thisLine = x + ", " 
      users.each do |user|
        thisLine = thisLine + userToSortedImages[user].index(x).to_s + ", "
      end
      puts thisLine
   end
   

# end
# end

puts output.size

