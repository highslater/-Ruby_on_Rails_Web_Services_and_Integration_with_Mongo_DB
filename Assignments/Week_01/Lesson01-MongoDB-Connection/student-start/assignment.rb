require 'mongo'
require 'pp'
require 'byebug'
require 'uri'
#Mongo::Logger.logger.level = ::Logger::INFO
#Mongo::Logger.logger.level = ::Logger::ERROR
#Mongo::Logger.logger.level = ::Logger::FATAL
#Mongo::Logger.logger.level = ::Logger::DEBUG
#Mongo::Logger.logger.level = ::Logger::WARN

Mongo::Logger.logger.level = Logger::INFO

class Solution
  @@db = nil

  #Implement a class method in the `Solution` class called `mongo_client` that will
  #create a `Mongo::Client` connection to the server using a URL (.e.g., 'mongodb://localhost:27017')
  #configure the client to use the `test` database
  #assign the client to @@db instance variable and return that client
  ## or just @@db = Mongo::Client.new('mongodb://localhost:27017/test')

  def self.mongo_client
    @@db = Mongo::Client.new('mongodb://localhost:27017')
    @@db = @@db.use('test')
  end


  #Implement a class method in the `Solution` class called `collection` that will
  #return the `zips` collection
  #self.mongo_client if not @@db

  def self.collection
    self.mongo_client if not @@db
    @@db[:zips]
  end


  #Implement an instance method in the `Solution` class called `sample` that will
  #return a single document from the `zips` collection from the database.
  #This does not have to be random. It can be first, last, or any other document in the collection.

  def sample
    self.class.collection.find.first
  end

end

#byebug
db=Solution.mongo_client
p db
zips=Solution.collection
p zips
s=Solution.new
pp s.sample

=begin

Solution
  rq01
    Database 'test' should exist with collection 'zips' with data
  rq02
    all work should be in assignment.rb file
    assignment.rb file imports the mongo gem
    Class Solution should exist in assignment
  rq03
    Solution implements a class method called mongo_client
    returns a mongo client connected to test collection
    mongo_client method returns a connection to test db
  rq04
    Solution implements aa class method called collection
    collection method returns a Mongo Collection to zips
    collection method returns the entire zip collection
  rq05
    Solution implements an instance method called sample
    sample method returns a single item from collection

Finished in 0.07385 seconds (files took 0.48112 seconds to load)
12 examples, 0 failures

=end
