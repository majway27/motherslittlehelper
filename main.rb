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
my_page = a.get(config['host'] + config['instance'] + '/').form_with(:name => 'auth_form') do |form|
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

## Set other key data mimicing "javascript:doSubmit() that validates and posts".  Mechanize doesn't support Javascript.  Set Other hidden data on form
## 11-23 RM, use Mechanize#post, for some reason submitting the report_form object(like above) doesn't work. Notably uri picks up a trailing action value and the action field on the form isn't set.
my_page = a.post config['host'] + config['instance'] + '/', 
  "selection_form" => "yes", 
  "d" => "appointplus356",
  "page" => "10",
  "m" => "2",
  "type" => "23",
  "auth" => "yes",
  # "action", aka request type
  "action" => "viewappts",
  "customer_id" => config["customer_id"],
  "customer_location_id" => config["location_id"],
  "day_name" => "any",
  "location_id" => config["location_id"],
  "id" => config["location_id"],
  "headquarters_id" => config["location_id"],
  "service_id" => "974",
  "e_id" => "782",
  # Set applicable children here. >0 children required.
  config["child1"] => "on",
  config["child2"] => "on",
  "next_date" => config["next_date"],
  "prev_date" => config["prev_date"],
  #"next_date" => config["next_date1"],
  #"prev_date" => config["prev_date1"],
  #"next_date" => config["next_date1"],
  #"prev_date" => config["prev_date1"],
  "starting_date" => config["starting_date"],
  "previous_service_id" => "974",
  # Set desired appointment date
  "date_ymd" => config["date_ymd"]

# Debug
pp my_page

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
