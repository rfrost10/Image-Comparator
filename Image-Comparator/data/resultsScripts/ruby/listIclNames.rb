require 'json'

# example usage: ruby listIclNames.rb ret_images_4_27_2015.json

filename = ARGV[0]
file = File.read(filename)

contents = JSON.parse(file)

iclDocs = contents['rows'].select{|x| x['doc']['type'] === "image_compare_list"}

iclDocs.each{|x| puts x['key']}
