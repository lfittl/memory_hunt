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

Authors
-------

- [Lukas Fittl](mailto:lukas@fittl.com)

License
-------

Copyright (c) 2014, Lukas Fittl <lukas@fittl.com><br>
memory_hunt is licensed under the 2-clause BSD license, see LICENSE file for details.
