
require 'csv'

#baseDir="/Users/jayashreekalpathy-cramer/Documents/rop/website/images/"
baseDir="/c/Users/Alan/Documents/ROP_keepers/"

#CSV.foreach("im_1_10_sorted.csv") do |row|
#CSV.foreach("imgId_set100.csv") do |row|
CSV.foreach("rank100_select25.csv") do |row|

  im= row[1]
  rank=row[2]
  use=row[3].to_i
  if use ==1
    cmd= "cp #{baseDir}#{im} #{baseDir}sorted2/#{rank}_#{im}"
    #puts cmd
    `#{cmd}`
  end
end

=begin
baseDir="/Users/jayashreekalpathy-cramer/Documents/rop/website/Image-Comparator/images/first_set_of_ten/"

CSV.foreach("im_1_10_sorted.csv") do |row|
  im= row[1]
  rank=row[2]
  cmd= "cp #{baseDir}#{im} #{baseDir}sorted/#{rank}_#{im}"
  puts cmd
  `#{cmd}`
end
=end
