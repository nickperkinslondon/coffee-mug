coffeemug = require './coffeemug'
person_page = require './person_page'

person =
  name:'Nick'
  age:43
  numbers:[1234567,98765432]
  kids:[{
    name:'Annabelle'
    age:19
  },{
    name:'Spencer'
    age:16
  }]


http = require 'http'
srv = http.createServer (req, res)->
  res.writeHead 200, 'Content-Type': 'text/html'

  html = coffeemug.render person, person_page

  console.log html
  res.end html


srv.listen(1337, '127.0.0.1')
console.log '---------Server running at http://127.0.0.1:1337/'
