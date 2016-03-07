require 'sinatra'; require 'haml'; require 'sass'; require 'mailchimp'; require './lib/constants.rb'
require './lib/helpers.rb'; require 'sinatra/partial'; require 'koala'

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
post '/email-subscribe' do
  mailchimp = Mailchimp::API.new(ENV['MAILCHIMP'])
  mailchimp.lists.subscribe(MAILCHIMP-LIST-ID, 
                   { "email" => params[:email],
                     "euid" => rand(999999),
                     "leid" => LIST
                   })
end

### ROUTES ###
get '/' do
  @product = "Short Description of Product"
  haml :index, :layout => :default_layout, :locals => { active: "home" }
end

get '/events' do
  @graph = Koala::Facebook::API.new(ENV['FACEBOOK'])
  events = @graph.get_connection(FB_PAGE, "events")
  haml :events, :layout => :default_layout, :locals => { active: "events"}
end
