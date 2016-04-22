require 'sinatra'; require 'haml'; require 'sass'; require 'mailchimp'; require './lib/constants.rb'
require './lib/helpers.rb'; require 'sinatra/partial'; require 'koala'; require 'sendgrid-ruby'

OFFLINE_DEV = TRUE;

### SETUP ###
configure do
  set :scss, {:style => :compressed, :debug_info => false}
  set :partial_template_engine, :haml
end

configure :development, :test do
  set :bind, '0.0.0.0'
  set :port, 3000
  require 'pry'
end

### ASSETS ###
get '/css/:name.css' do |name|
  content_type :css
  scss "sass/#{name}".to_sym, :layout => false
end

### EMAIL SUBSCRIBE ###
post '/subscribe' do
  mailchimp = Mailchimp::API.new(ENV['MAILCHIMP'])
  mailchimp.lists.subscribe(MAILCHIMP-LIST-ID,
                   { "email" => params[:email],
                     "euid" => rand(999999),
                     "leid" => LIST
                   })
end

### CONTACT INPUT ###
post '/contact-form' do
  client = SendGrid::Client.new(api_key: ENV['SENDGRID'])
  mail = SendGrid::Mail.new do |m|
    m.to = BIZ_EMAIL
    m.from = 'noreply@' + request.host
    m.subject = 'NEW WEBSITE CONTACT MESSAGE'
    m.text = params[:message]
  end
  res = client.send(mail)
end

### ROUTES ###
get '/' do
  if OFFLINE_DEV
    events = []
  else
    @graph = Koala::Facebook::API.new("CAAMq2lPRBFIBAAGTcV7E6TJ99v7aYDdYCj4ZBqxOpZBZAQtLaJtS7Pb9wZCsrNFLtprsPAew55FaBf7txmnnfMwxTRDQ91jlv5ysd1nsSEeJGgatKqyudESSmFXYAUrqsqTd3AFDLcFhvtzfZASXRZAepGDuddxli4ReRw8xHjE5lyTiFrOrlOsTtAn26di0Ei9jZCTlSZBJ5tSMWZCqBKn5y")
    events = @graph.get_connection(FB_PAGE, "events")
  end
  @product = "Short Description of Product"
  haml :index, :layout => :default_layout, :locals => { active: "home", events: events }
end

get '/events' do
  if OFFLINE_DEV
    events = []
  else
    @graph = Koala::Facebook::API.new(ENV['FACEBOOK'])
    events = @graph.get_connection(FB_PAGE, "events")
  end
  haml :events, :layout => :default_layout, :locals => { active: "events"}
end

get '/contact-us' do
  haml :contact, :layout => :default_layout, :locals => { active: "home" }
end

