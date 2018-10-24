require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'


# Iteration: Clean Phone Numbers
# Similar to the zip codes the phone numbers suffer from multiple formats and inconsistencies. 
# If we wanted to allow individuals to sign up for mobile alerts with the phone numbers we 
# would need to make sure all of the numbers are valid and well-formed.

# If the phone number is less than 10 digits assume that it is a bad number
# If the phone number is 10 digits assume that it is good
# If the phone number is 11 digits and the first number is 1, trim the 1 and use the first 10 digits
# If the phone number is 11 digits and the first number is not 1, then it is a bad number
# If the phone number is more than 11 digits assume that it is a bad number

def clean_phone_numbers(phone_number)
	#input is a random assormentment of STRING numbers

	# step 1: convert phone number into a string with only digits
	phone_number_array = phone_number.split('')
	only_digits = phone_number_array.keep_if { |digit| digit =~ /\d/ }
    num_count = only_digits.length

    

	if num_count == 10
		only_digits.insert(3,'-')
        only_digits.insert(7,'-')
		p only_digits.join
	elsif num_count < 10
		p 'invalid number'
	elsif (num_count == 11)&&(only_digits[0] == 1)
		only_digits.insert(3,'-')
        only_digits.insert(7,'-')
		p only_digits.join
	elsif num_count > 11
		p 'invalid number'
	elsif (num_count == 11)&&(only_digits[0] != 1)
		p 'invalid number'
	end	
				
				
				
				




	#output : 123-456-7890

 
       					
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

contents.each do |row|
  id = row[0]
  name = row[:first_name]
  zipcode = clean_zipcode(row[:zipcode])

  clean_phone_numbers(row[:homephone])

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_thank_you_letters(id,form_letter)
end

