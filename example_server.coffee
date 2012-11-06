
http = require 'http'
coffeemug = require './coffeemug'

srv = http.createServer (req,res)->
  res.end coffeemug.render ->

    @html ->
      @head ->
        @style """
          body{
            font-family:Arial;
          }
        """
      @body ->
        @h1 'CoffeeMug'
        @h2 'Write HTML with Coffeescript'

srv.listen 8001,'0.0.0.0'

