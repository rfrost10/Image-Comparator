require 'couchrest'
require 'securerandom'
require 'pry'
require 'csv'

# Include config variables - BB 
 require './Configuration' 
 include Configuration 
  
DNS = Configuration::DNS 
DB_PORT = Configuration::DB_PORT 
DB_ADMIN_USER = Configuration::DB_ADMIN_USER 
DB_ADMIN_PASS = Configuration::DB_ADMIN_PASS 
IMAGES_DB = Configuration::IMAGES_DB 

#  # Include config variables - BB

imageFolder=ARGV[0]
imageSetName=ARGV[1]
fromCSV=ARGV[2]

if (ARGV.size < 2) then
  puts "Usage: ruby : #{$PROGRAM_NAME} <imageFolder> <imageSetName>";
  puts "Where:\n"
  puts "1 - <imageFolder> is the full path to folder/directory where the images are located.\n"
  puts "2 - <imageSetName> can be used by makeICLFromImageSetName.rb and makeImageClassifyListImageSet.rb later.\n"
  puts "3 - <fromCSV> name of csv file in imageFolder."
  exit
end

# TBD: add warning if imageSetName already exists

if (fromCSV.nil?)
  # ims=Dir.glob("#{imageFolder}/*") --delete if it doesn't break anything
  ims=Dir.glob("#{imageFolder}/*")
  # binding.pry
else
# csv
  ims = {}
  loop = 0
  CSV.foreach("#{imageFolder}/#{fromCSV}") do |row|
    if (loop > 0)
        ims[row[0]] = {}
        for i in 0..(row.length-2)
          ims[row[0]][i] = row[i+1]
        end
    end
    loop += 1
    
    
  end
  
end


#connect to db, create if does not exist
puts ADMIN_PARTY
if ADMIN_PARTY == true
  @db = CouchRest.database!("http://#{DNS}:#{DB_PORT}/#{IMAGES_DB}")
else
  @db = CouchRest.database!("http://#{DB_ADMIN_USER}:#{DB_ADMIN_PASS}@#{DNS}:#{DB_PORT}/#{IMAGES_DB}")
end

res= @db.view('basic_views/count_image_docs')#.to_yaml
puts res
imgCount= res["rows"].size
if imgCount >0
  #sleep 10000
  imgCount= res["rows"][0]["value"].to_i
end


ims.each_with_index  do |im, idx|
  image_name = ""
  image_class = "None Provided"
  image_dataset = ""
  image_patient = ""
  image_qa_case_design = ""
  
  
  if (im.class == Array) 
    image_name = im[0]
    image_class = im[1][0]
    image_dataset = im[1][1]
    image_patient = im[1][2]
    image_qa_case_design = im[1][3]
  end
  puts image_name
  puts idx
  thisIm=image_name.split('/').last
  imClass=thisIm.split('.').last
  puts thisIm
  puts imClass
  uuid = SecureRandom.uuid
  
  
  obj = { 
  :origin => thisIm,
  :id => uuid,
  :type => "imageDoc",
  :imageSetName => imageSetName,
  :timeAdded => Time.now(),
  :class => image_class,
  :dataset => image_dataset,
  :patient => image_patient,
  :image_qa_case_design => image_qa_case_design,
  }
  
  # binding.pry  
  obj['_id']=(idx+imgCount+1).to_s
  puts obj
  response =@db.save_doc(obj)
  @db.put_attachment(obj, "image", File.open("#{imageFolder}/"+thisIm), :content_type => "image/#{imClass}")
end



