require 'sinatra'
require 'datamapper'

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/orchard.db")

# Trees in the orchard.
class Tree
  include DataMapper::Resource
  property :id, Serial
  property :tree_name, String

  has n, :apples    # "a tree has many apples"
  has n, :seeds, :through => :apples
end

# Apples on a Tree.
class Apple
  include DataMapper::Resource
  property :id, Serial
  property :apple_name, String

  belongs_to :tree # "an apple belongs to a tree..."
  has n, :seeds    # "...and has many seeds"
end

# Seeds in an Apple
class Seed
  include DataMapper::Resource
  property :id, Serial
  property :seed_name, String

  belongs_to :apple  # "and a seed belongs to an apple"
end

DataMapper.finalize.auto_upgrade!
