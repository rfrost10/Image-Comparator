
require 'couchrest'
require 'securerandom'


#baseDir="/Users/jkc/Documents/retinalImaging/website/Image-Comparator/"


imageFolder=ARGV[0]
imageSetName=ARGV[1]

if (ARGV.size != 2) then
  puts "Usage: ruby : #{$PROGRAM_NAME}.rb <imageFolder> <imageSetName>";
  puts "where imageFolder is the full path to folder/directory where the images are located."
  puts "And imageSetName can be used by makeImageCompareList"
  exit
end

# add warning if imageSetName already exists

ims=Dir.glob("#{imageFolder}/*")

dbname = "ret_images"

#connect to db, create if does not exist
@db = CouchRest.database!("http://admin:PASSword_123@ec2-18-234-167-89.compute-1.amazonaws.com:5984/#{dbname}")

#CouchRest.put("http://localhost:5984/testdb/doc", 'name' => 'test', 'date' => Date.current)

res= @db.view('basic_views/count_image_docs')#.to_yaml
puts res
imgCount= res["rows"].size
if imgCount >0
#sleep 10000
  imgCount= res["rows"][0]["value"].to_i
end


ims.each_with_index  do |im, idx|
  puts im
  puts idx
  thisIm=im.split('/').last
  imClass=thisIm.split('.').last
  puts thisIm
  puts imClass
  uuid = SecureRandom.uuid

  obj = { :origin => "#{thisIm}",
  :id => uuid,
  :type => "imageDoc",
  :imageSetName => imageSetName,
  :timeAdded => Time.now()

}
obj['_id']=(idx+imgCount+1).to_s
#puts obj
response =@db.save_doc(obj)

@db.put_attachment(obj, "image", File.open(im), :content_type => "image/#{imClass}")

#@db.save_doc(obj)

end


