require 'sinatra'
require 'datamapper'

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
  property :fairy, Boolean
  property :elf, Boolean
  
  has 1, :bag # Each creature has 1 bag.
  has n, :apples, :through => :bag
end

# Each Creature has a Magic Bag.
class Bag
  include DataMapper::Resource
  property :id, Serial
  
  belongs_to :creature # Each bag belongs to one Creature.
  has n :apples #each bag can hold many apples
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