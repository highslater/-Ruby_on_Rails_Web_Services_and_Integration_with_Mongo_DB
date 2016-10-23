require 'mongo'
require 'json'
require 'pp'
require 'byebug'
Mongo::Logger.logger.level = ::Logger::INFO
#Mongo::Logger.logger.level = ::Logger::DEBUG

=begin
{"_id"=>BSON::ObjectId('564c01c886c12c3d3d0003ca'),
 "number"=>970,
 "first_name"=>"LONNIE",
 "last_name"=>"FITZGERALD",
 "gender"=>"F",
 "group"=>"14 and under",
 "secs"=>2258}
=end

class Solution
  MONGO_URL='mongodb://localhost:27017'
  MONGO_DATABASE='test'
  RACE_COLLECTION='race1'

  # helper function to obtain connection to server and set connection to use specific DB
  # set environment variables MONGO_URL and MONGO_DATABASE to alternate values if not
  # using the default.
  def self.mongo_client
    url=ENV['MONGO_URL'] ||= MONGO_URL
    database=ENV['MONGO_DATABASE'] ||= MONGO_DATABASE
    db = Mongo::Client.new(url)
    @@db=db.use(database)
  end

  # helper method to obtain collection used to make race results. set environment
  # variable RACE_COLLECTION to alternate value if not using the default.
  def self.collection
    collection=ENV['RACE_COLLECTION'] ||= RACE_COLLECTION
    return mongo_client[collection]
  end

  # helper method that will load a file and return a parsed JSON document as a hash
  def self.load_hash(file_path)
    file=File.read(file_path)
    JSON.parse(file)
  end

  # initialization method to get reference to the collection for instance methods to use
  def initialize
    @coll=self.class.collection
  end

  #
  # Lecture 1: Create
  #

  def clear_collection
    # self.class.collection.delete_many({})
    # Implement all methods relative to the @coll instance
    # variable setup to reference the collection.
    @coll.delete_many({})
  end

  def load_collection(file_path)
    loadHash = self.class.load_hash(file_path)
    @coll.insert_many(loadHash)
  end

  def insert(race_result)
    #place solution here
    @coll.insert_one(race_result)
  end

=begin
$ rspec spec/lecture1_spec.rb
Solution
  rq01
    Solution implements an instance method called clear_collection
    clear_collection deletes all documents and returns a Mongo result object
  rq02
    Solution implements an instance method called load_collection
    load_collection inserts all json documents in a file and returns a Mongo result object
  rq03
    Solution implements an instance method called insert
    insert accepts a hash and inserts it into collects
6 examples, 0 failures
=end

  #
  # Lecture 2: Find By Prototype
  #

  def all(prototype={})
    @coll.find(prototype)
  end

  def find_by_name(fname, lname)
    @coll.find(:first_name => fname,:last_name => lname).projection(
      _id: false,
      gender: false,
      group: false,
      secs: false
    )
  end

=begin
$ rspec spec/lecture2_spec.rb
Solution
  rq01
    Solution implements an instance method called all
    Instance method all takes optional prototype hash
    method all takes returns all records filtered by hash
  rq02
    Solution implements an instance method called find_by_name
    Instance method find_by_name takes two parameters for first_name and last_name
    method all takes returns first names and last names of records filtered by first_name and last_name
6 examples, 0 failures
=end

  #
  # Lecture 3: Paging
  #

  def find_group_results(group, offset, limit)
    #place solution here
    @coll.find(:group => group).skip(offset).limit(limit).sort({:secs => 1}).projection(group: false, _id: false)
  end

=begin
$ rspec spec/lecture3_spec.rb
Solution
  Solution has instance_method find_group_results:
    Solution implements method
    accepts 3 parameters for group name, offset and limit values
    returns a Mongo results object with items only for a specified group
    forms a projection, sorts by ascending times and supports limit
    supports offsets in gathering results
5 examples, 0 failures
=end

  #
  # Lecture 4: Find By Criteria
  #

  def find_between(min, max)
    @coll.find(
      :secs => {:$gt => min, :$lt => max}
    )
  end

=begin
$ rspec spec/lecture4_spec.rb -e rq01
Run options: include {:full_description=>/rq01/}
Solution
  rq01
    Solution implements instance method find_between
    find_between accepts a min and max value
    find_between finds all race results with a time between input parameter values (exclusive)
3 examples, 0 failures
=end

  def find_by_letter(letter, offset, limit)
    @coll.find(
      :last_name => {:$regex=>"^#{letter.upcase}.+"}
    ).skip(offset).limit(limit).sort(
      :last_name => 1
    )
  end

=begin
$ rspec spec/lecture4_spec.rb -e rq02
Run options: include {:full_description=>/rq02/}
Solution
  rq02
    Solution implements instance method find_by_letter
    find_between accepts parameters for letter, offset and limit
    finds all race results (ascending by last name) with last name that starts with letter
3 examples, 0 failures
=end

  #
  # Lecture 5: Updates
  #

  def update_racer(racer)
    @coll.find(_id: racer[:_id]).replace_one(racer)
  end

  def add_time(number, secs)
    @coll.find(number: number).update_one(:$inc => {:secs => secs})
  end

=begin
$ rspec spec/lecture5_spec.rb
Solution
  rq01
    Solution implements an instance method called update_racer
    update_racer accepts a hash or racer properties
    update_racer finds a racer associated with given _id property and updates fields with given hash
  rq02
    Solution implements an instance method called add_time
    add_time accepts racer number and amount of time in seconds
    add_time finds a racer by number and increments time without retrieving document
6 examples, 0 failures
=end

end

s=Solution.new
race1=Solution.collection
