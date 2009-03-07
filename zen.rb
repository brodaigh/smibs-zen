require 'rubygems'
require 'sinatra'
require 'data_mapper'
gem 'haml', '~> 2.0'

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/../smibs/db/dev5.sqlite3")

class Fabric 
  include DataMapper::Resource
  storage_names[:default]='fabrics'
  property :id, Integer, :serial => true
  property :title, String
  property :image, String
  property :metres, Float
  property :payment_received, Boolean
  property :source, String
  property :cost_per_metre, Float

end

class Order 
  include DataMapper::Resource
  property :id, Integer, :serial => true
  property :buyers_name, String
  property :buyers_email, String
  property :recipients_address, Text
  property :recipients_name, String
  property :overseas, Boolean
  property :payment_preference, String
  property :created_on, Date
  property :created_at, DateTime
  property :updated_at, DateTime
  property :payment, Boolean, :default => false
  property :posted, Boolean, :default => false
  property :emailed, Boolean, :default => false
  property :notes, Text
  has n, :fabrics, :through => Resource
  
end

get '/' do
  @orders = Order.all
  haml :index
end

get '/orders/:id' do
  @order = Order.get(params[:id])
  haml :show
end

get '/fabrics/new' do 
  haml :"fabrics/new"
end
  
post "/fabrics/create" do
  @fabric = Fabric.create(Hash[*params.collect {|k,v| [k.to_s.gsub('fabric_', ''), v] }.flatten])
  if @fabric.save
    redirect "/fabrics/index"
  end
end

get "/fabrics/index" do
  @fabrics = Fabric.all
  haml :"fabrics/index"
end
  
get "/stylesheets/style.css" do
  content_type 'text/css'
  headers "Expires" => (Time.now + 60*60*24*356*3).httpdate   
  sass :"stylesheets/style"
end

helpers do
  def versioned(stylesheet)
    "/stylesheets/style.css?" + File.mtime(File.join(Sinatra.application.options.views, "stylesheets", "style.sass")).to_i.to_s
  end
  def YesOrNo(var)
    var == true ? "yes" : "no"
  end

end

##Admin