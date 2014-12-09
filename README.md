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
YourApp::Application.config.middleware.insert_before 0, MemoryHunt::Middleware
```

Now, when you run any non-asset request it will run the request twice, and then output something like:

```
17:38:02 web.1    | I, [2014-11-24T17:38:02.401281 #12568]  INFO -- : Memory leak statistics saved to tmp/report_1418131796.txt
```

That file contains statistics on memory that wasn't GCed in a subsequent duplicate request being run. It looks like this:

```
Report for /testaction

Rails app
---------

Gems
----
70 left-over OBJECTs referenced by gems/newrelic_rpm-3.9.7.266/lib/new_relic/transaction_sample.rb:104
  33 OBJECT at gems/newrelic_rpm-3.9.7.266/lib/new_relic/transaction_sample.rb:104
  32 ARRAY at gems/newrelic_rpm-3.9.7.266/lib/new_relic/transaction_sample/segment.rb:37
  1 HASH at gems/newrelic_rpm-3.9.7.266/lib/new_relic/transaction_sample/segment.rb:127
  1 STRING at gems/newrelic_rpm-3.9.7.266/lib/new_relic/agent/instrumentation/middleware_proxy.rb:63
   value (50): "Middleware/Rack/OmniAuth::Strategies::Twitter/call"
  1 STRING at gems/newrelic_rpm-3.9.7.266/lib/new_relic/agent/instrumentation/active_record_helper.rb:41
   value (19): "Database/SQL/select"
  1 STRING at gems/newrelic_rpm-3.9.7.266/lib/new_relic/agent/instrumentation/action_view_subscriber.rb:68
   value (28): "View/text template/Rendering"
  1 STRING at gems/newrelic_rpm-3.9.7.266/lib/new_relic/agent/transaction.rb:191
   value (28): "Nested/Controller/pages/ping"
33 left-over ARRAYs referenced by gems/newrelic_rpm-3.9.7.266/lib/new_relic/transaction_sample/segment.rb:37
  33 OBJECT at gems/newrelic_rpm-3.9.7.266/lib/new_relic/transaction_sample.rb:104
14 left-over HASHs referenced by gems/activerecord-4.1.8/lib/active_record/result.rb:105
  14 STRING at gems/activerecord-4.1.8/lib/active_record/result.rb:99
   value (20): "background_image_url"
   value (4): "kind"
   value (10): "updated_at"
   value (10): "created_at"
   value (6): "layout"
   value (16): "header_image_url"
   value (12): "sorting_type"
   value (8): "promoted"
   value (9): "image_url"
   value (5): "title"
   value (4): "name"
   value (4): "slug"
   value (7): "user_id"
   value (2): "id"

...
```

Note that the output might contain false positives (like here with New Relic and the ActiveRecord statement cache),
it is up to you to investigate more closely whether there is an actual leak.

Authors
-------

- [Lukas Fittl](mailto:lukas@fittl.com)

License
-------

Copyright (c) 2014, Lukas Fittl <lukas@fittl.com><br>
memory_hunt is licensed under the 2-clause BSD license, see LICENSE file for details.
