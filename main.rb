require 'rubygems'
require 'mechanize'
require 'yaml'
#require 'logger'

config = YAML.load_file("config.yaml")

a = Mechanize.new { |agent|
  agent.user_agent_alias = 'Mac Safari'
  #agent.log = Logger.new(STDERR)
  #agent.set_proxy("localhost", 8888)
}

# Instance, User, Pass
my_page = a.get('https://booknow.appointment-plus.com/' +  config['instance'] + '/').form_with(:name => 'auth_form') do |form|
  form['loginname'] = config["user"]
  form['password'] = config["pass"]
end.submit

#puts "Debug: Login"

# Pick Time Frame
report_form = my_page.form('myForm1')
report_form.service_id = config['service_id']
my_page = a.submit(report_form)

# Pick Kid Type
report_form = my_page.form('myForm1')
report_form.e_id = config["e_id"]
my_page = a.submit(report_form)

# Set Children
report_form = my_page.form('myForm1')
# Check as many checkboxes as needed
report_form.checkbox_with(config["child1"]).check
report_form.checkbox_with(config["child2"]).check

## Set other key data mimicing "javascript:doSubmit() that validates and posts".  Mechanize doesn't support Javascript.
# Set desired appointment date
report_form.date_ymd = config["date_ymd"]
report_form.starting_date = config["starting_date"]
# "action", aka request type
report_form.action = 'viewappts'

## Other hidden data on form
report_form.selection_form = 'yes'
report_form.d = 'appointplus356'
report_form.page = '10'
report_form.m = '2'
report_form.type = '23'
report_form.auth = 'yes'
report_form.customer_id = config["customer_id"]
report_form.day_name = 'any'
report_form.location_id = config["location_id"]
report_form.id = config["location_id"]
report_form.next_date = config["next_date"]
report_form.prev_date = config["prev_date"]
report_form.next_date = config["next_date1"]
report_form.prev_date = config["prev_date1"]
report_form.next_date = config["next_date1"]
report_form.prev_date = config["prev_date1"]

my_page = a.submit(report_form)

# Debug
#pp my_page

#my_page.links.each do |link|
#  puts link.text
#end

#puts "Debug: Logout"

# Logout when finished
my_page = a.click(my_page.link_with(:text => /Log/))

# Verify logout
my_page.links.each do |link|
  puts link.text
end
