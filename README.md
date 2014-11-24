memory_hunt
===========

Experimental middleware for finding leaks caused by the request being run.

This requires MRI Ruby 2.1+ to use the necessary ObjectSpace extensions.


Installation
------------

```
gem install memory_hunt
```


Usage with Rails
----------------

```ruby
YourApp::Application.config.middleware.insert_after ActionDispatch::RequestId, MemoryHunt::Middleware
```

Now, when you run any non-asset request it will run the request twice, and then output something like:

```
17:38:02 web.1    | I, [2014-11-24T17:38:02.401281 #12568]  INFO -- : Memory leak statistics saved to tmp/report_b309df1d-190d-40ba-a064-503da809af06.txt
```

That file contains statistics on memory that wasn't GCed after a GC run + subsequent request and another GC run. It looks like this:

```
Report for /something

Rails app
---------
Leaked 2 CLASS objects of size 0/1344 at: /vagrant/lib/something.rb:3
Leaked 1 CLASS objects of size 0/672 at: /vagrant/lib/something.rb:4

Total Size: 0/2016

Gems
----

Leaked 551 HASH objects of size 0/108832 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/actionpack-4.1.8/lib/action_dispatch/journey/gtg/transition_table.rb:112
Leaked 520 STRING objects of size 3400/579 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/pg-0.17.1/lib/pg/result.rb:10
Leaked 483 STRING objects of size 1642/26 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/actionpack-4.1.8/lib/action_dispatch/journey/gtg/builder.rb:29
Leaked 417 ARRAY objects of size 0/7360 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/actionpack-4.1.8/lib/action_dispatch/journey/gtg/transition_table.rb:15
Leaked 378 ARRAY objects of size 0/296 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/pg-0.17.1/lib/pg/result.rb:10
Leaked 266 DATA objects of size 0/183008 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activemodel-4.1.8/lib/active_model/attribute_methods.rb:385
Leaked 266 NODE objects of size 0/0 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activemodel-4.1.8/lib/active_model/attribute_methods.rb:385
Leaked 266 ARRAY objects of size 0/0 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activemodel-4.1.8/lib/active_model/attribute_methods.rb:385
Leaked 239 STRING objects of size 8285/7533 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activerecord-4.1.8/lib/active_record/connection_adapters/abstract/quoting.rb:56
Leaked 238 STRING objects of size 4798/2375 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activemodel-4.1.8/lib/active_model/attribute_methods.rb:385
Leaked 226 STRING objects of size 6283/6396 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activerecord-4.1.8/lib/active_record/migration.rb:882
Leaked 116 STRING objects of size 2650/5289 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activesupport-4.1.8/lib/active_support/inflector/methods.rb:71
Leaked 113 STRUCT objects of size 0/25312 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activerecord-4.1.8/lib/active_record/migration.rb:888
Leaked 113 STRING objects of size 0/0 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activerecord-4.1.8/lib/active_record/migration.rb:879
Leaked 98 DATA objects of size 0/97536 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activerecord-4.1.8/lib/active_record/attribute_methods.rb:45
Leaked 68 STRING objects of size 2490/2456 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activerecord-4.1.8/lib/active_record/attribute_methods.rb:45
Leaked 68 STRING objects of size 1343/776 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activerecord-4.1.8/lib/active_record/attribute_methods.rb:27
Leaked 64 ARRAY objects of size 0/0 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activerecord-4.1.8/lib/active_record/attribute_methods.rb:45
Leaked 64 DATA objects of size 0/3072 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activerecord-4.1.8/lib/active_record/attribute_methods.rb:46
Leaked 64 NODE objects of size 0/0 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activerecord-4.1.8/lib/active_record/attribute_methods.rb:45
Leaked 62 STRING objects of size 672/0 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/thread_safe-0.3.4/lib/thread_safe/non_concurrent_cache_backend.rb:21
Leaked 56 STRING objects of size 1441/1225 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activerecord-4.1.8/lib/active_record/migration.rb:826
Leaked 52 OBJECT objects of size 0/5408 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activerecord-4.1.8/lib/active_record/model_schema.rb:215
Leaked 52 OBJECT objects of size 0/5408 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activerecord-4.1.8/lib/active_record/connection_adapters/postgresql/schema_statements.rb:189
Leaked 52 STRING objects of size 557/59 at: /home/vagrant/.rvm/gems/ruby-2.1.4/gems/activerecord-4.1.8/lib/active_record/model_schema.rb:223
Leaked 50 STRING objects of size 510/26 at: /home/vagrant/.rvm/rubies/ruby-2.1.4/lib/ruby/2.1.0/set.rb:270
```

Authors
-------

- [Lukas Fittl](mailto:lukas@fittl.com)

License
-------

Copyright (c) 2014, Lukas Fittl <lukas@fittl.com><br>
memory_hunt is licensed under the 2-clause BSD license, see LICENSE file for details.
