```console

irb(main):001:0> require './gridfs_loader.rb'  
=> true  

irb(main):002:0> GridfsLoader.mongo_client
creating connection mongodb://localhost:27017 test
D, [2016-10-29T18:28:41.907683 #16820] DEBUG -- : MONGODB | Adding localhost:27017 to the cluster.
=> #<Mongo::Client:0x70083682463300 cluster=localhost:27017>

irb(main):003:0> os_file = File.open("./image2.jpg")
=> #<File:./image2.jpg>

irb(main):004:0> grid_file = Mongo::Grid::File.new(os_file.read)
=> #<Mongo::Grid::File:0x70083681952560 filename=>

irb(main):008:0* grid_file.methods
=> [:chunk_size, :content_type, :filename, :id, :md5, :upload_date, :chunks, :info, :==, :data, :inspect, :psych_to_yaml, :to_yaml, :to_yaml_properties, :to_bson_key, :to_bson_normalized_key, :to_bson_normalized_value, :nil?, :===, :=~, :!~, :eql?, :hash, :<=>, :class, :singleton_class, :clone, :dup, :itself, :taint, :tainted?, :untaint, :untrust, :untrusted?, :trust, :freeze, :frozen?, :to_s, :methods, :singleton_methods, :protected_methods, :private_methods, :public_methods, :instance_variables, :instance_variable_get, :instance_variable_set, :instance_variable_defined?, :remove_instance_variable, :instance_of?, :kind_of?, :is_a?, :tap, :send, :public_send, :respond_to?, :extend, :display, :method, :public_method, :singleton_method, :define_singleton_method, :object_id, :to_enum, :enum_for, :equal?, :!, :!=, :instance_eval, :instance_exec, :__send__, :__id__]


irb(main):011:0* c = GridfsLoader.mongo_client
=> #<Mongo::Client:0x70083682463300 cluster=localhost:27017>
irb(main):012:0> r = c.database.fs.insert_one(grid_file)
=> BSON::ObjectId('5815253e01701541b49f1e13')


irb(main):014:0* stored_file = c.database.fs.find_one(:_id=>BSON::ObjectId('5815253e01701541b49f1e13'))
=> #<Mongo::Grid::File:0x70083683754240 filename=>

irb(main):018:0> os_file2 = File.open("./exported_copy.jpg", "w")
=> #<File:./exported_copy.jpg>

irb(main):019:0> stored_file.chunks.reduce([]) {|x, chunk| os_file2 << chunk.data.data}
=> #<File:./exported_copy.jpg>

irb(main):020:0> description = {}
=> {}

irb(main):022:0* description[:filename] = "myfile.jpg"
=> "myfile.jpg"
irb(main):023:0> description[:content_type] = "image/jpeg"
=> "image/jpeg"
irb(main):024:0> description[:metadata] = {:author=> "kiran", :topic=> "nice spot"}
=> {:author=>"kiran", :topic=>"nice spot"}
irb(main):025:0> grid_file = Mongo::Grid::File.new(os_file.read, description)
=> #<Mongo::Grid::File:0x70083682623560 filename=myfile.jpg>

irb(main):027:0* r = c.database.fs.insert_one(grid_file)
=> BSON::ObjectId('5815541a01701541b49f1e30')


irb(main):042:0> c.database.fs.find_one(:contentType=> 'image/jpeg', :filename=>'myfile.jpg')
=> #<Mongo::Grid::File:0x70083680655780 filename=myfile.jpg>

irb(main):048:0> c.database.fs.find_one(:"metadata.author"=> "kirin", :"metadata.topic"=> {:$regex=> "spot"})
=> #<Mongo::Grid::File:0x70083683758360 filename=myfile.jpg>

irb(main):055:0* pp c.database.fs.find(:contentType=> 'image/jpeg', :filename=>'myfile.jpg').first;nil
{"_id"=>BSON::ObjectId('5815541a01701541b49f1e30'),
 "chunkSize"=>261120,
 "uploadDate"=>2016-10-30 01:57:59 UTC,
 "contentType"=>"image/jpeg",
 "filename"=>"myfile.jpg",
 "metadata"=>{"author"=>"kiran", "topic"=>"nice spot"},
 "length"=>0,
 "md5"=>"d41d8cd98f00b204e9800998ecf8427e"}
=> nil

irb(main):058:0* pp c.database.fs.find(:"metadata.author"=> "kirin", :"metadata.topic"=> {:$regex=> "spot"}).first;nil
{"_id"=>BSON::ObjectId('58151caa0170153dce299db6'),
 "chunkSize"=>261120,
 "uploadDate"=>2016-10-29 22:02:05 UTC,
 "contentType"=>"image.jpg",
 "filename"=>"myfile.jpg",
 "metadata"=>{"author"=>"kirin", "topic"=>"nice spot"},
 "length"=>0,
 "md5"=>"d41d8cd98f00b204e9800998ecf8427e"}
=> nil

irb(main):059:0> pp c.database.fs.find(:content_type=> 'image/jpeg', :filename=>'myfile.jpg').first;nil

irb(main):061:0> id = c.database.fs.find(:"metadata.author"=>"kiran").first[:_id]
=> BSON::ObjectId('5815541a01701541b49f1e30')

irb(main):062:0> r = c.database.fs.find(:_id=>id).delete_one
=> #<Mongo::Operation::Result:70083676723380 documents=[{"ok"=>1, "n"=>1}]>

irb(main):063:0> r.deleted_count
=> 1


```