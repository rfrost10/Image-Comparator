
require 'couchrest'
require 'securerandom'


imageFolder=ARGV[0]
imageSetName=ARGV[1]
dns = ARGV[2]
userpass = ARGV[3]
dbname = ARGV[4]

#DNS = "ec2-35-171-23-49.compute-1.amazonaws.com"

if (ARGV.size != 5) then
  puts "Usage: ruby : #{$PROGRAM_NAME} <imageFolder> <imageSetName> <DNS> <user:password> <dbname>";
  puts "Where:\n"
  puts "1 - <imageFolder> is the full path to folder/directory where the images are located.\n"
  puts "2 - <imageSetName> can be used by makeICLFromImageSetName.rb later.\n"
  puts "3 - <DNS> is ip-address or VM DNS.\n"
  puts "4 - <user:password> is your VMs username and password entered explicitly as user:password.\n"
  puts "5 - <dbname> is the name of the database you want to add images to."
  exit
end

# add warning if imageSetName already exists

ims=Dir.glob("#{imageFolder}/*")


#connect to db, create if does not exist
@db = CouchRest.database!("http://#{userpass}@#{dns}:5984/#{dbname}")


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

end


