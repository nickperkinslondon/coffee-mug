coffeemug = require './coffeemug'

project_page_template = require './project_page'

data_for_template =
  name:'coffee-mug'
  author:'nickperkinslondon'
  email:'nickperkinslondon@gmail.com'
  location:'London, Ontario, Canada'
  url:'https://github.com/nickperkinslondon/coffee-mug'
  description:"coffee-mug is a pure CoffeeScript HTML generator for node.js inspired by coffeekup"
  features:[
    'no magic'
    'pure coffeescript'
    'nice output'
    'one language to rule them all'
    'nice stacktrace on template errors'
  ]

html = coffeemug.render data_for_template, project_page_template
console.log html


serve_page = ()->
  http = require 'http'
  srv = http.createServer (req, res)->
    res.writeHead 200, 'Content-Type': 'text/html'
    res.end html
  srv.listen(1337, '127.0.0.1')
  console.log '---------Server running at http://127.0.0.1:1337/'

serve_page()
