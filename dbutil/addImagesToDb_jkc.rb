require 'couchrest'
require 'securerandom'

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

if (ARGV.size != 5) then
  puts "Usage: ruby : #{$PROGRAM_NAME} <imageFolder> <imageSetName>";
  puts "Where:\n"
  puts "1 - <imageFolder> is the full path to folder/directory where the images are located.\n"
  puts "2 - <imageSetName> can be used by makeICLFromImageSetName.rb later.\n"
  exit
end

# add warning if imageSetName already exists

ims=Dir.glob("#{imageFolder}/*")


#connect to db, create if does not exist
@db = CouchRest.database!("http://#{DB_ADMIN_USER}:#{DB_ADMIN_PASS}@#{DNS}:#{DB_PORT}/#{IMAGES_DB}")


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


