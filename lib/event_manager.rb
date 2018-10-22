puts "EventManager Initialized!"

#CHECKING IF FILE EXISTS?
# - - - - - - - - - - - - - - -
# if File.exist? "event_attendees.csv"
# 	puts 'this file exists'
# end	

#READING FILE
# - - - - - - - - - - - - - - -
# contents = File.read "event_attendees.csv"
# puts contents

#READ FILE LINE BY LINE
# - - - - - - - - - - - - - - -
lines = File.readlines "event_attendees.csv"

lines.each_with_index do |line,index|
  next if index == 0
  columns = line.split(",")
  name = columns[2]
  puts name
end