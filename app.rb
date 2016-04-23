require 'sinatra'; require 'haml'; require 'sass'; require 'mailchimp'; require './lib/constants.rb'
require './lib/helpers.rb'; require 'sinatra/partial'; require 'koala'; require 'sendgrid-ruby'
require 'curb'

OFFLINE_DEV = FALSE;

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
   raw_events = Curl::Easy.perform('https://graph.facebook.com/v2.6/563294870511008/?access_token=CAACEdEose0cBAMrztIL1OZBTrm7IiNikpSsOSxJVK4ApWEDgv4ekCTAZAYxymmBfengyJnhOoYzilqSt8Wm68YuP96M31ioyji9TZBL5gkJsJVtEzVtCNClqk6qjB5pKQzNqqfc6iERyAnr8mjEAU4ModLZALmulcVuqRmTNO9t5hTF5CP39ZADX4ZAYbtfY8hVSZApKWn4MXdvW8UZCUO4H/')
   events = JSON.parse(raw_events.body)
  end
  @product = "Short Description of Product"
  haml :index, :layout => :default_layout, :locals => { active: "home", events: events }
end

get '/events' do
  if OFFLINE_DEV
    events = []
  else
    raw_events = Curl::Easy.perform('https://graph.facebook.com/v2.6/563294870511008/?access_token=CAACEdEose0cBAMrztIL1OZBTrm7IiNikpSsOSxJVK4ApWEDgv4ekCTAZAYxymmBfengyJnhOoYzilqSt8Wm68YuP96M31ioyji9TZBL5gkJsJVtEzVtCNClqk6qjB5pKQzNqqfc6iERyAnr8mjEAU4ModLZALmulcVuqRmTNO9t5hTF5CP39ZADX4ZAYbtfY8hVSZApKWn4MXdvW8UZCUO4H/')
    events = JSON.parse(raw_events.body)
  end
  haml :events, :layout => :default_layout, :locals => { active: "events", events: events}
end

get '/contact-us' do
  events = []
  haml :contact, :layout => :default_layout, :locals => { active: "home", events: events }
end
