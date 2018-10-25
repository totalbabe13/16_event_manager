require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'
require 'date'

def get_hour(registration_time)
  time_string = registration_time.gsub("/",'-')
  reg_date =  DateTime.strptime(time_string.to_s, '%m-%d-%Y %H:%M')
  reg_date.hour
end	

def clean_phone_numbers(phone_number)
	
	phone_number_array = phone_number.split('')
	only_digits = phone_number_array.keep_if { |digit| digit =~ /\d/ }
    num_count = only_digits.length
	if num_count == 10
		only_digits.insert(3,'-')
        only_digits.insert(7,'-')
	    only_digits.join
	elsif num_count < 10
	    'invalid number'
	elsif (num_count == 11)&&(only_digits[0] == 1)
		only_digits.insert(3,'-')
        only_digits.insert(7,'-')
	    only_digits.join
	elsif num_count > 11
	    'invalid number'
	elsif (num_count == 11)&&(only_digits[0] != 1)
	    'invalid number'
	end	
				       					
end


def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")[0..4]
end

def legislators_by_zipcode(zip)
  civic_info = Google::Apis::CivicinfoV2::CivicInfoService.new
  civic_info.key = 'AIzaSyClRzDqDh5MsXwnCWi0kOiiBivP6JsSyBw'

  begin
    civic_info.representative_info_by_address(
      address: zip,
      levels: 'country',
      roles: ['legislatorUpperBody', 'legislatorLowerBody']
    ).officials
  rescue
    "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
  end
end

def save_thank_you_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename,'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager initialized."

contents = CSV.open 'event_attendees.csv', headers: true, header_converters: :symbol

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter
hours = []

contents.each do |row|
  id = row[0]
  name = row[:first_name]
# - - - - - - - 
  hours << get_hour(row[:regdate])
# - - - - - - -   

  zipcode = clean_zipcode(row[:zipcode])

  clean_phone_numbers(row[:homephone])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id,form_letter)
end
sum_of_hours = 0
hours.each {|hour| sum_of_hours += hour }
p sum_of_hours/19

