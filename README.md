# rails-lite
  A web server MVC framework written in Ruby, inspired by the functionality of Ruby on Rails' application controller.
  
 #### How to use:
   - Represent tables in a database as global variables (for an example, see [router_sever.rb](https://github.com/gmkohler/rails-lite/blob/master/bin/router_server.rb))
   - Write controller classes that inherit from [ControllerBase](https://github.com/gmkohler/rails-lite/blob/master/lib/controller_base.rb).
   - Construct views in the `views` folder with names corresponding to `controller_names`.
   - Draw routes using Regexps (see [router_sever.rb](https://github.com/gmkohler/rails-lite/blob/master/bin/router_server.rb)).

## Features
 - Converts URL query strings into a deeply nested params hash for use in controller classes.
 - Converts semantic route drawing syntax into `Route` objects via metaprogramming.
 - Selectively persists `flash` messages across multiple renders via a `flash.now` method.

## To-dos
 - Impelement a resources command to draw the six standard CRUD routes
 - Integrate with an object-relational mapping app (e.g., [ActiveRecord Lite](https://github.com/gmkohler/active-record-lite)).
