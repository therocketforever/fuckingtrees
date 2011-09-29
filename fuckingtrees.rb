require 'sinatra'
require 'datamapper'
require 'digest/sha1'

enable :sessions

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/orchard.db")

# Trees in the orchard.
class Tree
  include DataMapper::Resource
  property :id, Serial, :key => false
  property :tree_name, String, :key => true

  has n, :apples    # "a tree has many apples"
  has n, :seeds, :through => :apples
end

# Apples on a Tree.
class Apple
  include DataMapper::Resource
  property :id, Serial, :key => false
  property :apple_name, String, :key => true

  belongs_to :tree # "an apple belongs to a tree..."
  belongs_to :bag # Apples con be in a bag.
  has n, :seeds    # "...and has many seeds"
end

# Seeds in an Apple
class Seed
  include DataMapper::Resource
  property :id, Serial, :key => false
  property :seed_name, String, :key => true

  belongs_to :apple  # "and a seed belongs to an apple"
end

# Magic Creatures in charge.
class Creature
  include DataMapper::Resource
  property :id, Serial
  property :name, String
  property :login, String, :key => true, :length => (3..40), :required => true
  property :hashed_password, String
  property :salt, String
  property :fairy, Boolean
  property :elf, Boolean
  
  validates_pressence_of :login
  
  has 1, :bag # Each creature has 1 bag.
  has n, :apples, :through => :bag
  
  def password=(pass)
    @password = pass
    self.salt = Creature.random_string(10) unless self.salt
    self.hashed_password = Creature.encrypt(@password, self.salt)
  end
  
  def self.encrypt(pass, salt)
    Digest::SHA1.hexdigest(pass + salt)
  end
  
  def self.random_string(len)
    chars = ("a".."z").to_a + ("A".."Z").to_a + ("0".."9").to_a
    str = ""
    1.upto(len) { |i| str << chars[rand(char.size-1)] }
    return str
  end
end

# Each Creature has a Magic Bag.
class Bag
  include DataMapper::Resource
  property :id, Serial
  
  belongs_to :creature # Each bag belongs to one Creature.
  has n, :apples #each bag can hold many apples
end

DataMapper.finalize.auto_upgrade!

get '/' do
  @title = 'Orchard'
  erb :orchard
end

get '/trees' do
  @tree = Tree.get params[:id]
  erb :trees
end

get '/login' do
  @title = 'Login'
  erb :login
end

post '/login' do
  if session[:creature] = Creature.authenticate(params[:login], params[:password])
    redirect '/'
  else
    redirect '/login'
  end
end

get '/logout' do
  logout!
  redirect '/'
end