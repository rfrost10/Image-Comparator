require 'json'

# example usage: ruby imageId2Origin.rb ret_images_4_27_2015.json

filename = ARGV[0]
file = File.read(filename)

contents = JSON.parse(file)

imageDocs = contents['rows'].select{|x| x['doc']['type'] === "imageDoc"}

imageDocs.each{|x| puts x['key'] + "\t" + x['doc']['origin']}

#puts imageDocs
