require "./Configuration"
include Configuration

puts ("DNS: " + Configuration::DNS)
puts ("IMAGES_DB: " + Configuration::IMAGES_DB)
puts ("DB_PORT: " + Configuration::DB_PORT)
puts ("HTP_PORT: " + Configuration::HTTP_PORT)
puts ("DB_ADMIN_USER: " + Configuration::DB_ADMIN_USER)
puts ("DB_ADMIN_PASS: " + Configuration::DB_ADMIN_PASS)

