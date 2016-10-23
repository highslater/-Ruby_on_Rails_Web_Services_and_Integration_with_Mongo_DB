require 'mongo'
require 'pp'

class Racer
  include ActiveModel::Model

  attr_accessor :id, :number, :first_name, :last_name, :gender, :group, :secs

  def self.mongo_client
    Mongoid::Clients.default
  end

  def self.collection
    return mongo_client['racers']
  end

  def self.all(prototype={}, sort = {number:1}, skip = 0, limit = nil)
    return collection.find(prototype).sort(sort).skip(skip).limit(limit) if !limit.nil?
    collection.find(prototype).sort(sort).skip(skip)
  end

  def self.find id
    # @id = document[:_id].to_s
    # :_id=>BSON::ObjectId.from_string(@id)
    if id.is_a? String
      result = collection.find({ _id: BSON::ObjectId.from_string(id)}).first
    else
      # Racer.find(racer[:_id])
      # (racer[:_id]) => BSON::ObjectId('5809af74017015361c515a73')
      result = collection.find({_id: id}).first
    end
    return result.nil? ? nil : Racer.new(result)
  end

  def self.paginate(params)
    page = (params[:page] || 1).to_i
    limit = (params[:per_page] || 30).to_i
    skip = (page-1) * limit
    sort = {:number => 1}

    racers = []
    all({}, sort, skip, limit).each do |doc|
      racers << Racer.new(doc)
    end
    # pp racers
    total = all({}, sort, 0, 1).count
    # pp total
    WillPaginate::Collection.create(page, limit, total) do |pager| pager.replace(racers)
    end
  end

  def created_at
    nil
  end

  def destroy
    # self.class.collection.delete_one({:number => @number})_id: BSON::ObjectId.from_string(id)}
    self.class.collection.delete_one({_id: BSON::ObjectId.from_string(@id)})
  end

  def initialize(params={})
    # watch for @id vs :_id vs :id
    @id = params[:_id].nil? ? params[:id] : params[:_id].to_s()
    @number = params[:number].to_i
    @first_name = params[:first_name].to_s
    @last_name = params[:last_name].to_s
    @gender = params[:gender].to_s
    @group = params[:group].to_s
    @secs = params[:secs].to_i
  end

  def persisted?
    !@id.nil?
  end

  def save
    doc = {
      :number => @number,
      :first_name => @first_name,
      :last_name => @last_name,
      :gender => @gender,
      :group => @group,
      :secs => @secs
    }

    result = self.class.collection.insert_one(doc)
    #if result.n
    #@id = self.class.collection.find(doc).first[:_id].to_s # OK
    @id = result.inserted_id.to_s # BETTER
    #end
  end

  # update the values for this instance
  def update(params)
    @number = params[:number].to_i
    @first_name = params[:first_name]
    @last_name = params[:last_name]
    @gender = params[:gender]
    @group = params[:group]
    @secs = params[:secs].to_i

    prams = {
      :number => @number,
      :first_name => @first_name,
      :last_name => @last_name,
      :gender => @gender,
      :group => @group,
      :secs => @secs
    }
    # params.slice!(:number, :first_name, :last_name, :gender, :group, :secs)
    # self.class.collection.find(:_id => @id).update_one(params) #THIS SHOULD WORK FIND() NEEDS IMPROVEMENT
    # self.class.collection.find(:_id => BSON::ObjectId.from_string(@id)).replace_one(params)
    self.class.collection.find(:_id => BSON::ObjectId.from_string(@id)).replace_one(prams)
  end


  def updated_at
    nil
  end


end
